//
//  FRCBaseTableViewController.m
//

#import "FRCBaseTableViewController.h"

@implementation FRCBaseTableViewController

#pragma mark - Lifecycle

/**
 *  dealloc
 */
- (void)dealloc {
  [_fetchedResultsController release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  prefixedSectionsCount
 */
- (NSUInteger)prefixedSectionsCount {
  // Normally a UITableView's number of sections needs to match it's NSFetchedResultsController number of
  // sections. However, there might be times when you want to prefix some sections before the actual
  // fetched objects sections (like for rows that might be commands). By returning the number of 
  // prefixed sections here, we can normalize any NSIndexPaths that the fetched controller relies on.
  return 0;
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count] + self.prefixedSectionsCount;
}

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger normalizedSection = section - self.prefixedSectionsCount;
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:normalizedSection];
  return [sectionInfo numberOfObjects];
}

/**
 *  tableView:editingStyleForRowAtIndexPath
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  // Default to returning UITableViewCellEditingStyleNone because based on the Apple docs regarding UITableView editing
  // a cell will enter it's editable state if the method below, tableView:commitEditingStyle is declared. Since we're
  // effectively in a base clase here, just declaring that method is not enough to make a cell editable for us. 
  // Derived classes should override this method and return UITableViewCellEditingStyleDelete where appropriate.
  return UITableViewCellEditingStyleNone;
}

/**
 *  tableView:commitEditingStyle:forRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:[self normalizeIndexPath:indexPath]];
    [self.client deleteObject:managedObject];
  }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

/**
 *  controllerWillChangeContent
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

/**
 *  controllerDidChangeContent
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

/**
 *  controller:didChangeSection:atIndex:forChangeType
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type {
  NSUInteger normalizedSectionIndex = sectionIndex + self.prefixedSectionsCount;
  
  switch(type) {
    case NSFetchedResultsChangeInsert: {
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:normalizedSectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
    }
      
    case NSFetchedResultsChangeDelete: {
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:normalizedSectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
    }
  }
}

/**
 *  controller:didChangeObject:atIndexPath:forChangeType:newIndexPath
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  NSIndexPath *normalizedIndexPath = [NSIndexPath indexPathForRow:indexPath.row 
                                                        inSection:(indexPath.section + self.prefixedSectionsCount)];
  
  NSIndexPath *normalizedNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row 
                                                           inSection:(newIndexPath.section + self.prefixedSectionsCount)];
  switch(type) {
    case NSFetchedResultsChangeInsert: {
      [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:normalizedNewIndexPath] 
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
    }
      
    case NSFetchedResultsChangeDelete: {
      [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:normalizedIndexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
    }
      
    case NSFetchedResultsChangeUpdate: {
      [self configureCell:[self.tableView cellForRowAtIndexPath:normalizedIndexPath] atIndexPath:normalizedIndexPath];
      break;
    }
      
    case NSFetchedResultsChangeMove: {
      [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:normalizedIndexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:normalizedNewIndexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
    }
  }
}

#pragma mark - Instance Methods

/**
 *  normalizeIndexPath
 */
- (NSIndexPath *)normalizeIndexPath:(NSIndexPath *)indexPath {
  return [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - self.prefixedSectionsCount)];
}

@end