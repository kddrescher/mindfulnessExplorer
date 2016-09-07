//
//  ActivityEditViewController.m
//

#import "ActivityEditViewController.h"
#import "Activity.h"
#import "Client.h"
#import "DateFormViewController.h"
#import "EmailBuilder.h"
#import "Exercise.h"
#import "FormViewController.h"
#import "MenuFormViewController.h"
#import "NSString+VPDString.h"
#import "TextViewFormViewController.h"
#import "UIFactory.h"

@implementation ActivityEditViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client:activity
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client activity:(Activity *)activity {
  self = [self initWithStyle:style client:client managedObject:activity];
  if (self != nil) {
    self.editingExistingLogEntry = (activity != nil);
    
    // Setup navigation title and buttons.
    self.navigationItem.title = (activity == nil ? NSLocalizedString(@"Add Activity", nil) : NSLocalizedString(@"Edit Activity", nil));
  }
  
  return self;
}

#pragma mark - Property Accessors

/**
 *  scratchObjectEntityName
 */
- (NSString *)scratchObjectEntityName {
  return @"Activity";
}

/**
 *  activity
 */
- (Activity *)activity {
  return (Activity *)(self.scratchObject);
}

/**
 *  emailBuilder
 */
- (EmailBuilder *)emailBuilder {
  return [[[EmailBuilder alloc] initWithActivity:self.activity] autorelease];
}

#pragma mark - Instance Methods

/**
 *  setActivityExercise
 */
- (void)setActivityExercise:(Exercise *)exercise {
  Exercise *exerciseInScratchContext = (Exercise *)[self.scratchManagedObjectContext objectWithID:exercise.objectID];
  self.activity.exercise = exerciseInScratchContext;
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return ACTIVITY_TABLE_VIEW_SECTION_COUNT;
}

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDetailStyleFromTableView:tableView];
  cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  
  switch (indexPath.section) {
    case kActivityTableViewSectionExercise: {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.text = NSLocalizedString(@"Exercise", nil);
      cell.detailTextLabel.text = self.activity.exercise.title;
      break;
    }

    case kActivityTableViewSectionDate: {
      self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
      self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
      
      cell.textLabel.text = NSLocalizedString(@"Date", nil);
      cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.activity.date];
      break;
    }

    case kActivityTableViewSectionTime: {
      self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
      self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
      
      cell.textLabel.text = NSLocalizedString(@"Time of Practice", nil);
      cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.activity.date];
      break;
    }

    case kActivityTableViewSectionDuration: {
      cell.textLabel.text = NSLocalizedString(@"Duration", nil);
      cell.detailTextLabel.text = [NSString stringWithTimeInterval:[self.activity.duration doubleValue]];
      break;
    }

    case kActivityTableViewSectionAudio: {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = NSLocalizedString(@"Audio Guided", nil);

      UISwitch *audioSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
      audioSwitch.on = [self.activity.audio boolValue];
      [audioSwitch addTarget:self action:@selector(handleAudioValueChanged:) forControlEvents:UIControlEventValueChanged];
      cell.accessoryView = audioSwitch;
      
      [audioSwitch release];
      break;
    }
      
    case kActivityTableViewSectionComments: {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.text = NSLocalizedString(@"Comments", nil);
      cell.detailTextLabel.text = self.activity.comments;
      break;
    }
  }

  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FormViewController *formViewController = nil;
  NSString *attributeKey = nil;
  
  switch (indexPath.section) {
    case kActivityTableViewSectionExercise: {
      formViewController = [[MenuFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                  client:self.client 
                                                              fieldTitle:NSLocalizedString(@"Exercise", nil)];
      ((MenuFormViewController *)formViewController).allowMultipleSelections = NO;
      ((MenuFormViewController *)formViewController).fetchedResultsController = [self.client fetchedResultsControllerForExercises];
      if (self.activity.exercise != nil) {
        [(MenuFormViewController *)formViewController setSelectedManagedObjects:[NSSet setWithObject:self.activity.exercise]];
      }
      attributeKey = @"exercise"; 
      break;
    } 
      
    case kActivityTableViewSectionDate: {
      formViewController = [[DateFormViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client fieldTitle:NSLocalizedString(@"Date", nil)];
      [(DateFormViewController *)formViewController setDate:self.activity.date];
      [(DateFormViewController *)formViewController setMaximumDate:[NSDate date]];
      [(DateFormViewController *)formViewController setDatePickerMode:UIDatePickerModeDate];
      attributeKey = @"date";
      break;
    }
      
    case kActivityTableViewSectionTime: {
      formViewController = [[DateFormViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client fieldTitle:NSLocalizedString(@"Time of Practice", nil)];
      [(DateFormViewController *)formViewController setDate:self.activity.date];
      [(DateFormViewController *)formViewController setDatePickerMode:UIDatePickerModeTime];
      attributeKey = @"date";
      break;
    }
      
    case kActivityTableViewSectionDuration: {
      NSNumber *duration = self.activity.duration;
      NSTimeInterval interval = (duration != nil ? [duration doubleValue] : 60.0 * 5);
      formViewController = [[DateFormViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client fieldTitle:NSLocalizedString(@"Duration", nil)];
      [(DateFormViewController *)formViewController setTimeInterval:interval];
      [(DateFormViewController *)formViewController setDatePickerMode:UIDatePickerModeCountDownTimer];
      attributeKey = @"duration";
      break;
    }
      
    case kActivityTableViewSectionAudio: {
      // No-op for this row.
      break;
    }
      
    case kActivityTableViewSectionComments: {
      formViewController = [[TextViewFormViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client fieldTitle:NSLocalizedString(@"Comments", nil)];
      [(TextViewFormViewController *)formViewController setInitialText:self.activity.comments];
      attributeKey = @"comments";
      break;
    }
  }
  
  if (formViewController != nil) {
    formViewController.doneBlock = ^(id value) {
      if (indexPath.section == kActivityTableViewSectionExercise) {
        NSSet *menuValues = (NSSet *)value;
        NSMutableSet *localContextObjects = [NSMutableSet setWithCapacity:[menuValues count]];
        
        // Selected managed objects from the menu are likely not in our scratch managed object context.
        [menuValues enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
          NSManagedObject *managedObjectValue = (NSManagedObject *)obj;
          [localContextObjects addObject:[self.scratchManagedObjectContext objectWithID:[managedObjectValue objectID]]]; 
        }];
        
        value = [localContextObjects anyObject];
      }

      [self.activity setValue:value forKey:attributeKey];
      [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:formViewController animated:YES];
    [formViewController release];
  }
}

#pragma mark - Event Handlers

/**
 *  handleDoneButtonTapped
 */
- (void)handleDoneButtonTapped:(id)sender {
  if (self.activity.exercise == nil) {
    NSString *alertTitle = NSLocalizedString(@"Missing Exercise", nil);
    NSString *alertMessage = NSLocalizedString(@"Please select an exercise in order to save this activity.", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
  } else {
    [super handleDoneButtonTapped:sender];
  }
}

/**
 *  handleAudioValueChanged
 */
- (void)handleAudioValueChanged:(id)sender {
  UISwitch *audioSwitch = (UISwitch *)sender;
  self.activity.audio = [NSNumber numberWithBool:audioSwitch.on];
}

#pragma mark - Instance Methods

/**
 *  populateDefaultValuesWithNewManagedObject
 */
- (void)populateDefaultValuesWithNewManagedObject:(NSManagedObject *)managedObject {
  Activity *activity = (Activity *)managedObject;
  activity.date = [NSDate date];
  activity.duration = [NSNumber numberWithDouble:60.0 * 10];
  activity.audio = [NSNumber numberWithBool:NO];
}

@end
