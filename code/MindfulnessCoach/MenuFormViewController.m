//
//  MenuFormViewController.m
//

#import "MenuFormViewController.h"
#import "Client.h"
#import "TextFieldFormViewController.h"
#import "UIFactory.h"

@implementation MenuFormViewController


#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    _titleKey = [@"title" copy];
    _allowMultipleSelections = NO;
    _allowEmptySelection = NO;
    _allowUserAdditions = NO;
    _selectedManagedObjects = [[NSMutableSet alloc] initWithCapacity:8];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_titleKey release];
  [_userAdditionPlaceholderText release];
  [_selectedManagedObjects release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  fieldValue
 */
- (id)fieldValue {
  return [_selectedManagedObjects count] == 0 ? nil : [NSSet setWithSet:_selectedManagedObjects];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1 + (self.allowUserAdditions ? 1 : 0);
}

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == kMenuFormTableViewSectionOther) {
    return 1;
  }
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  
  if (indexPath.section == kMenuFormTableViewSectionItems) {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:self.titleKey];
    
    if ([_selectedManagedObjects containsObject:managedObject]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
  } else if (indexPath.section == kMenuFormTableViewSectionOther) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = NSLocalizedString(@"Other", nil);
  }
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == kMenuFormTableViewSectionItems) {
    NSManagedObject *selectedManagedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // If the object in question is not already selected, then either clear out the previous selections and
    // add this one, or append this selection to the existing selection set.
    if ([_selectedManagedObjects containsObject:selectedManagedObject]) {
      if (self.allowEmptySelection || [_selectedManagedObjects count] > 1) {
        [_selectedManagedObjects removeObject:selectedManagedObject];
      }
    } else {
      if (self.allowMultipleSelections == NO) {
        [_selectedManagedObjects removeAllObjects];
      }
      
      [_selectedManagedObjects addObject:selectedManagedObject];
    }
    
    [[tableView indexPathsForVisibleRows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      NSIndexPath *visibleIndexPath = (NSIndexPath *)obj;
      if (visibleIndexPath.section == kMenuFormTableViewSectionItems) {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:visibleIndexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:visibleIndexPath];
        
        cell.accessoryType = [_selectedManagedObjects containsObject:managedObject] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
      }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  } else if (indexPath.section == kMenuFormTableViewSectionOther) {
    TextFieldFormViewController *textFieldViewController = [[TextFieldFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                                       client:self.client 
                                                                                                   fieldTitle:NSLocalizedString(@"Other", nil)];
    textFieldViewController.placeholderText = self.userAdditionPlaceholderText;
    textFieldViewController.doneBlock = ^(id value) {
      NSString *title = (NSString *)value;
      if (title != nil && [title length] > 0) {
        // Rank the newly created item after the highest ranked existing item.
        NSManagedObject *lastManagedObject = [[self.fetchedResultsController fetchedObjects] lastObject];
        NSNumber *rank = [NSNumber numberWithInteger:([[lastManagedObject valueForKey:@"rank"] integerValue] + 1)];
        
        NSDictionary *itemValues = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", rank, @"rank", nil];
        NSEntityDescription *entityDescription = lastManagedObject.entity;
        
        NSManagedObject *newManagedObject = [self.client insertNewObjectForEntityForName:entityDescription.name 
                                                                              withValues:itemValues];
        
        [_selectedManagedObjects addObject:newManagedObject];
        [itemValues release];
      }
    };
    
    [self.navigationController pushViewController:textFieldViewController animated:YES];
    [textFieldViewController release];
  }
}

#pragma mark - Instance Methods

/**
 *  setSelectedManagedObjects
 */
- (void)setSelectedManagedObjects:(NSSet *)selectedObjects {
  [_selectedManagedObjects removeAllObjects];
  
  // Make sure we use the managed objects from our local context.
  [selectedObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    NSManagedObject *remoteObject = (NSManagedObject *)obj;
    
    NSManagedObjectContext *localContext = self.fetchedResultsController.managedObjectContext;
    NSManagedObject *localObject = [localContext objectWithID:[remoteObject objectID]];
    [_selectedManagedObjects addObject:localObject];
  }];
}


@end
