//
//  RemindersEditViewController.h
//

#import "BaseEditViewController.h"
#import "AppConstants.h"

typedef enum {
  RemindersEditModeLogReminder = 0,      
  RemindersEditModeRandomReminders
} RemindersEditMode;

enum {
  kRemindersTableViewSectionFrequency = 0,
  kRemindersTableViewSectionDate,
  kRemindersTableViewSectionSound
};

@class NotificationsManager;

@interface RemindersEditViewController : BaseEditViewController

// Properties
@property(nonatomic, assign) RemindersEditMode editMode;
@property(nonatomic, assign) NotificationFrequency frequency;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, assign) BOOL audioAlert;
@property(nonatomic, retain) NotificationsManager *notificationsManager;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client editMode:(RemindersEditMode)editMode;

// Event Handlers
- (void)handleAudioValueChanged:(id)sender;
- (void)handleSaveButtonTapped:(id)sender;
- (void)handleCancelButtonTapped:(id)sender;

// Instance Methods
- (void)rebuildNotifications;
- (NSCalendarUnit)calendarUnitFromNotificationFrequency:(NotificationFrequency)frequency;
- (void)saveToUserDefaults;
- (void)restoreFromUserDefaults;

@end
