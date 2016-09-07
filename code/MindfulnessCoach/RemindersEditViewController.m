//
//  RemindersEditViewController.m
//

#import "RemindersEditViewController.h"
#import "Action.h"
#import "BlackoutsViewController.h"
#import "DateFormViewController.h"
#import "NotificationFrequencyFormViewController.h"
#import "NotificationsManager.h"
#import "NSDate+VPDDate.h"
#import "NSString+VPDString.h"
#import "UIFactory.h"

#define kUserDefaultsKeyLogFrequency @"gov.va.mindfulnesscoach.log.frequency"
#define kUserDefaultsKeyLogDate @"gov.va.mindfulnesscoach.log.date"
#define kUserDefaultsKeyLogAudioAlert @"gov.va.mindfulnesscoach.log.audio"

#define kUserDefaultsKeyRandomFrequency @"gov.va.mindfulnesscoach.random.frequency"
#define kUserDefaultsKeyRandomAudioAlert @"gov.va.mindfulnesscoach.random.audio"

@implementation RemindersEditViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client:editMode
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client editMode:(RemindersEditMode)editMode {
  self = [self initWithStyle:style client:client];
  if (self != nil) {
    _editMode = editMode;
    _frequency = NotificationFrequencyNone;
    _date = [[NSDate alloc] init];
    _audioAlert = NO;
    _notificationsManager = [[NotificationsManager alloc] initWithClient:client application:[UIApplication sharedApplication]];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                       target:self 
                                                                                       action:@selector(handleSaveButtonTapped:)];
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    [saveBarButtonItem release];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                         target:self 
                                                                         action:@selector(handleCancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    [cancelBarButtonItem release];
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self restoreFromUserDefaults];
  
  NSString *headerText = nil;
  if (self.editMode == RemindersEditModeLogReminder) {
    headerText = NSLocalizedString(@"Set reminders to remind yourself to fill in the mindfulness "
                                   "log. Whether you are recording activities that you did in this "
                                   "app or on your own, it is important to keep track of your progress "
                                   "over time and to maintain an active practice.", nil);
  } else if (self.editMode == RemindersEditModeRandomReminders) {
    headerText = NSLocalizedString(@"Set up random reminders to pop up on your phone over the course "
                                   "of days or weeks. Each time, they will alert you to reset your "
                                   "awareness, consider your current situation, and to be mindful "
                                   "of the moment that you are currently living. You can set times "
                                   "when you would rather not be disturbed.", nil);
  }
  
  if (headerText != nil) {
    UIView *headerView = [UIFactory tableHeaderViewWithText:headerText
                                                  imageName:nil
                                                      width:self.view.frame.size.width - (kUIViewHorizontalMargin * 2)
                                                     styled:NO];

    self.tableView.tableHeaderView = headerView;
  }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_date release];
  [_notificationsManager release];
  [super dealloc];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
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
  UITableViewCell *cell = nil;

  if (indexPath.section == kRemindersTableViewSectionSound) {
    cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
    UISwitch *audioSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    audioSwitch.on = self.audioAlert;
    [audioSwitch addTarget:self action:@selector(handleAudioValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = audioSwitch;
    
    [audioSwitch release];
  } else {
    cell = [UIFactory cellWithDetailStyleFromTableView:tableView];
  }

  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FormViewController *formViewController = nil;
  
  switch (indexPath.section) {
    case kRemindersTableViewSectionFrequency: {
      formViewController = [[NotificationFrequencyFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                   client:self.client 
                                                                               fieldTitle:NSLocalizedString(@"Frequency", nil)];
      [(NotificationFrequencyFormViewController *)formViewController setFrequency:self.frequency];
      formViewController.doneBlock = ^(id value) {
        self.frequency = [(NSNumber *)value integerValue];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
      };
      break;
    }
      
    case kRemindersTableViewSectionDate: {
      if (self.editMode == RemindersEditModeLogReminder) {
        formViewController = [[DateFormViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                    client:self.client 
                                                                fieldTitle:NSLocalizedString(@"Time of day", nil)];
        [(DateFormViewController *)formViewController setDate:self.date];
        [(DateFormViewController *)formViewController setDatePickerMode:UIDatePickerModeTime];
        formViewController.doneBlock = ^(id value) {
          self.date = value;
          [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
      } else if (self.editMode == RemindersEditModeRandomReminders) {
        BlackoutsViewController *viewController = [[BlackoutsViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
      }
      break;
    }
      
    case kRemindersTableViewSectionSound: {
      // Intentionally left empty.
      break;
    }
  }
    
  if (formViewController != nil) {
    [self.navigationController pushViewController:formViewController animated:YES];
    [formViewController release];
  }
}

#pragma mark - Event Handlers

/**
 *  handleAudioValueChanged
 */
- (void)handleAudioValueChanged:(id)sender {
  UISwitch *audioSwitch = (UISwitch *)sender;
  self.audioAlert = audioSwitch.on;
}

/**
 *  handleSaveButtonTapped
 */
- (void)handleSaveButtonTapped:(id)sender {
  [self.notificationsManager cancelAllNotifications];
  [self rebuildNotifications];
  [self saveToUserDefaults];
  [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  handleCancelButtonTapped
 */
- (void)handleCancelButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Instance Methods

/**
 *  configureCell:atIndexPath
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case kRemindersTableViewSectionFrequency: {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.text = NSLocalizedString(@"Frequency", nil);
      cell.detailTextLabel.text = [NSString stringWithNotificationFrequency:self.frequency];
      break;
    }
      
    case kRemindersTableViewSectionDate: {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      if (self.editMode == RemindersEditModeLogReminder) {
        cell.textLabel.text = NSLocalizedString(@"Time of day", nil);
        if (self.date == nil) {
          cell.detailTextLabel.text = nil;
        } else {
          self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
          self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
          
          cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.date]; 
        }
      } else if (self.editMode == RemindersEditModeRandomReminders) {
        cell.textLabel.text = NSLocalizedString(@"Times Not To Alert", nil);
      }
      break;
    }

    case kRemindersTableViewSectionSound: {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = NSLocalizedString(@"Audio Alert", nil);
      break;
    }
  }
}

/**
 *  rebuildNotifications
 */
- (void)rebuildNotifications {
  // Cancel any outstanding notifications for the current type.
  if (self.editMode == RemindersEditModeLogReminder) {
    [self.notificationsManager cancelNotificationsWithType:kLocalNotificationTypeLogReminder];
  } else if (self.editMode == RemindersEditModeRandomReminders) {
    [self.notificationsManager cancelNotificationsWithType:kLocalNotificationTypeRandomReminder];
  }
     
  // Skip anything else if the user has opted to no longer receive notifications.
  if (self.frequency == NotificationFrequencyNone) {
    return;
  }
  
  // Create a new local notification for the current settings.
  UILocalNotification *localNotification = [[UILocalNotification alloc] init];
  localNotification.alertAction = NSLocalizedString(@"Continue", nil);;
  localNotification.alertBody = NSLocalizedString(@"Track your mindfulness practice now.", nil);;
  localNotification.repeatInterval = [self calendarUnitFromNotificationFrequency:self.frequency];
  localNotification.timeZone = [NSTimeZone localTimeZone];
  
  if (self.editMode == RemindersEditModeLogReminder) {
    localNotification.fireDate = [self.notificationsManager nextNotificationDateFromDate:self.date];
    localNotification.userInfo = [NSDictionary dictionaryWithObject:kLocalNotificationTypeLogReminder forKey:kLocalNotificationTypeKey];
  } else if (self.editMode == RemindersEditModeRandomReminders) {
    localNotification.fireDate = [self.notificationsManager nextRandomNotificationDateFromDate:self.date frequency:[self calendarUnitFromNotificationFrequency:self.frequency]];
    localNotification.userInfo = [NSDictionary dictionaryWithObject:kLocalNotificationTypeRandomReminder forKey:kLocalNotificationTypeKey];
  }

  if (self.audioAlert) {
    localNotification.soundName = UILocalNotificationDefaultSoundName;
  }
  
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
  [localNotification release];
}

/**
 *  calendarUnitFromNotificationFrequency
 */
- (NSCalendarUnit)calendarUnitFromNotificationFrequency:(NotificationFrequency)frequency {
  switch (frequency) {
    case NotificationFrequencyDaily: {
      return NSDayCalendarUnit;
    } 

    case NotificationFrequencyWeekly:{
      return NSWeekCalendarUnit;
    }
            
    case NotificationFrequencyMonthly: {
      return NSMonthCalendarUnit;
    } 
      
    default: {
      return 0;
    }
  }
  
  return 0;
}

/**
 *  saveToUserDefaults
 */
- (void)saveToUserDefaults {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  if (self.editMode == RemindersEditModeLogReminder) {
    [defaults setInteger:self.frequency forKey:kUserDefaultsKeyLogFrequency];
    [defaults setObject:self.date forKey:kUserDefaultsKeyLogDate];
    [defaults setBool:self.audioAlert forKey:kUserDefaultsKeyLogAudioAlert];
  } else if (self.editMode == RemindersEditModeRandomReminders) {
    [defaults setInteger:self.frequency forKey:kUserDefaultsKeyRandomFrequency];
    [defaults setBool:self.audioAlert forKey:kUserDefaultsKeyRandomAudioAlert];
  }

  [defaults synchronize];
}

/**
 *  restoreFromUserDefaults
 */
- (void)restoreFromUserDefaults {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if (self.editMode == RemindersEditModeLogReminder) {
    self.frequency = [defaults integerForKey:kUserDefaultsKeyLogFrequency];
    self.date = [defaults objectForKey:kUserDefaultsKeyLogDate];
    self.audioAlert = [defaults boolForKey:kUserDefaultsKeyLogAudioAlert];
  } else if (self.editMode == RemindersEditModeRandomReminders) {
    self.frequency = [defaults integerForKey:kUserDefaultsKeyRandomFrequency];
    self.audioAlert = [defaults boolForKey:kUserDefaultsKeyRandomAudioAlert];
  }
  
  if (self.date == nil) {
    self.date = [NSDate date];
  }
}

@end
