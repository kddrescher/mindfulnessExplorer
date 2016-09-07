//
//  ExerciseEventEditViewController.m
//

#import "ExerciseEventEditViewController.h"
#import "Client.h"
#import "Exercise.h"
#import "MenuFormViewController.h"
#import "NotificationFrequencyFormViewController.h"
#import "NSString+VPDString.h"
#import "UIFactory.h"

@implementation ExerciseEventEditViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    _exercise = nil;
    _chime = YES;
    _notificationFrequency = NotificationFrequencyOneTime;
    
    // We don't need to show the 'Cancel' button for this view controller.
    self.navigationItem.leftBarButtonItem = nil;
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *headerText = NSLocalizedString(@"Select an activity from this app or fill in one of your own. "
                                           "You will then be able to plan a time in the future when you "
                                           "would like to do this activity. Reminders will help you "
                                           "maintain your practice over time.", nil);

  UIView *headerView = [UIFactory tableHeaderViewWithText:headerText
                                                imageName:nil
                                                    width:self.view.frame.size.width - (kUIViewHorizontalMargin * 2)
                                                   styled:NO];
  
  self.tableView.tableHeaderView = headerView;
  
  UIView *footerView = [UIFactory tableFooterViewWithButton:NSLocalizedString(@"Add Activity to Calendar", nil)];
  UIButton *button = (UIButton *)[footerView viewWithTag:kViewTagTableViewFooterButton];
  
  [button addTarget:self action:@selector(handleAddToCalendarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  
  self.tableView.tableFooterView = footerView;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_exercise release];
  
  [super dealloc];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Note: For now we are only showing the first section because the second and third
  // sections (Frequency and Chime) should really be set in the EventEditViewController.
  return 1;
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
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  
  switch (indexPath.section) {
    case kExerciseEventTableViewSectionExercise: {
      cell.detailTextLabel.text = self.exercise.title;
      cell.textLabel.text = NSLocalizedString(@"Activity", nil);
      break;
    }

    case kExerciseEventTableViewSectionFrequency: {
      cell.detailTextLabel.text = [NSString stringWithNotificationFrequency:self.notificationFrequency];
      cell.textLabel.text = NSLocalizedString(@"Frequency", nil);
      break;
    }

    case kExerciseEventTableViewSectionChime: {
      UISwitch *chimeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
      chimeSwitch.on = self.chime;
      [chimeSwitch addTarget:self action:@selector(handleChimeValueChanged:) forControlEvents:UIControlEventValueChanged];

      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.accessoryView = chimeSwitch;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = NSLocalizedString(@"Chime", nil);
      
      [chimeSwitch release];
      break;
    }
  }

  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return tableView.rowHeight;
}

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FormViewController *formViewController = nil;
  
  switch (indexPath.section) {
    case kExerciseEventTableViewSectionExercise: {
      formViewController = [[MenuFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                  client:self.client 
                                                              fieldTitle:NSLocalizedString(@"Exercise", nil)];
      ((MenuFormViewController *)formViewController).allowMultipleSelections = NO;
      ((MenuFormViewController *)formViewController).fetchedResultsController = [self.client fetchedResultsControllerForExercises];
      if (self.exercise != nil) {
        [(MenuFormViewController *)formViewController setSelectedManagedObjects:[NSSet setWithObject:self.exercise]];
      }
      break;
    } 
      
    case kExerciseEventTableViewSectionFrequency: {
      formViewController = [[NotificationFrequencyFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                   client:self.client 
                                                                               fieldTitle:NSLocalizedString(@"Frequency", nil)];
      [(NotificationFrequencyFormViewController *)formViewController setFrequency:self.notificationFrequency];
      break;
    }
      
  }
  
  if (formViewController != nil) {
    formViewController.doneBlock = ^(id value) {
      if (indexPath.section == kExerciseEventTableViewSectionExercise) {
        // No need to convert this to the local managed object context since we're just grabbing the exercise's title.
        NSSet *menuValues = (NSSet *)value;
        self.exercise = [menuValues anyObject];
      } else if (indexPath.section == kExerciseEventTableViewSectionFrequency) {
        self.notificationFrequency = [(NSNumber *)value integerValue];
      }
      
      [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:formViewController animated:YES];
    [formViewController release];
  }
}

#pragma mark - EKEventEditViewDelegate

/**
 *  eventEditViewController:didCompleteWithAction
 */
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
  // We're not actively doing anything with the newly created event, so just dismiss the view.
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Event Handlers

/**
 *  handleChimeValueChanged
 */
- (void)handleChimeValueChanged:(id)sender {
  UISwitch *chimeSwitch = (UISwitch *)sender;
  self.chime = chimeSwitch.on;
}

/**
 *  handleAddToCalendarButtonTapped
 */
- (void)handleAddToCalendarButtonTapped:(id)sender {
  EKEventStore *eventStore = [[EKEventStore alloc] init];
  
  if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
      dispatch_sync(dispatch_get_main_queue(), ^(void) {
        if (granted) {
          [self showEventControllerWithEventStore:eventStore];
        } else {
          NSString *alertMessage = NSLocalizedString(@"Mindfulness Coach does not have access to your calendars. "
                                                     "You can enable access in Privacy Settings.", nil);
          
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied", nil)
                                                              message:alertMessage
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles:nil];
          
          [alertView show];
          [alertView release];
        }
        [eventStore release];
      });
    }];
  } else {
    [self showEventControllerWithEventStore:eventStore];
    [eventStore release];
  }
}

/**
 *  showEventControllerWithEventStore
 */
- (void)showEventControllerWithEventStore:(EKEventStore *)eventStore {
  EKEvent *event = [EKEvent eventWithEventStore:eventStore];
  event.calendar = eventStore.defaultCalendarForNewEvents;
  event.title = self.exercise.title;
  
  EKEventEditViewController *viewController = [[EKEventEditViewController alloc] initWithNibName:nil bundle: nil];
  viewController.event = event;
  viewController.eventStore = eventStore;
  viewController.editViewDelegate = self;
  
  [self presentViewController:viewController animated:YES completion:nil];
  
  [viewController release];
}

@end
