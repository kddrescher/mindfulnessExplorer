//
//  AppConstants.h
//

#import <Foundation/Foundation.h>

// Application
extern NSString *const kApplicationContentPath;
extern NSString *const kFlurryAnalyticsAPIKey;
extern NSString *const kTestFlightAppToken;

// Action Accessories
extern NSString *const kActionAccessoryNone;

// Action Groups
extern NSString *const kActionGroupHome;
extern NSString *const kActionGroupLearn;
extern NSString *const kActionGroupPractice;
extern NSString *const kActionGroupTrack;
extern NSString *const kActionGroupRemind;
extern NSString *const kActionGroupAbout;

// Action Types
extern NSString *const kActionTypeDismissAndSetTabIndex;
extern NSString *const kActionTypeButtonMenu;
extern NSString *const kActionTypeMenu;
extern NSString *const kActionTypePage;
extern NSString *const kActionTypeRoot;

extern NSString *const kActionTypeEditActivity;
extern NSString *const kActionTypeViewActivities;
extern NSString *const kActionTypeViewActivityProgress;

extern NSString *const kActionTypeEditExerciseEvent;
extern NSString *const kActionTypeEditRandomReminders;
extern NSString *const kActionTypeEditLogReminder;

extern NSString *const kActionTypeShowSettings;

// HTML Content
extern NSString *const kContentHTMLLayoutPath;
extern NSString *const kContentHTMLLayoutPlaceholder;
extern NSString *const kContentHTMLBodyClassPlaceholder;

extern NSString *const kContentHTMLURLViewIntroductionScreen;
extern NSString *const kContentHTMLURLViewHomeScreen;
extern NSString *const kContentHTMLURLGoToAction;
extern NSString *const kContentHTMLURLGoToPage;
extern NSString *const kContentHTMLURLPlayVideo;
extern NSString *const kContentHTMLURLNewActivity;
extern NSString *const kContentHTMLURLViewSongsController;
extern NSString *const kContentHTMLURLViewPhotosController;
extern NSString *const kContentHTMLURLViewPracticePhotosController;
extern NSString *const kContentHTMLURLViewPracticeSongsController;
extern NSString *const kContentHTMLURLViewPracticeEnvironmentController;

extern NSString *const kContentHTMLURLLegalEULA;
extern NSString *const kContentHTMLURLLegalIntroduction;

// UILocalNotifications
extern NSString *const kLocalNotificationTypeKey;
extern NSString *const kLocalNotificationTypeRandomReminder;
extern NSString *const kLocalNotificationTypeLogReminder;

// User Defaults Keys
extern NSString *const kUserDefaultsKeyContentVersion;
extern NSString *const kUserDefaultsKeyViewedLegalScreens;
extern NSString *const kUserDefaultsKeyRecordUsageData;

// Images
extern NSString *const kBackgroundImageNameStripped;

// UIKit
extern NSInteger const kViewTagTableViewCellTextField;
extern NSInteger const kViewTagTableViewCellLabelDate;
extern NSInteger const kViewTagTableViewCellLabelAudio;
extern NSInteger const kViewTagTableViewCellLabelDuration;
extern NSInteger const kViewTagTableViewCellLabelTitle;
extern NSInteger const kViewTagTableViewCellLabelComments;
extern NSInteger const kViewTagTableViewCellShadowTextField;
extern NSInteger const kViewTagTableViewCellTextView;
extern NSInteger const kViewTagTableViewFooterButton;
extern NSInteger const kViewTagTableViewHeaderLabel;
extern NSInteger const kViewTagTableViewCellVariableHeightLabel;

extern CGFloat const kUIHeightButton;
extern CGFloat const kUIHeightDatePicker;
extern CGFloat const kUIHeightKeyboard;
extern CGFloat const kUIHeightTextField;
extern CGFloat const kUIHeightToolbar;
extern CGFloat const kUIHeightTableViewCellWithTextView;

extern CGFloat const kUIHeightRoundSwitch;
extern CGFloat const kUIWidthRoundSwitch;

extern CGFloat const kUIViewVerticalMargin;
extern CGFloat const kUIViewHorizontalMargin;

// Reminder Frequencies
typedef enum {
  NotificationFrequencyNone = 0,      
  NotificationFrequencyOneTime = 1 << 0,
  NotificationFrequencyDaily = 1 << 1,   
  NotificationFrequencyTwicePerDay = 1 << 2,
  NotificationFrequencyThricePerDay = 1 << 3,
  NotificationFrequencyEveryOtherDay = 1 << 4,
  NotificationFrequencyWeekly = 1 << 5,
  NotificationFrequencyMonthly = 1 << 6  
} NotificationFrequency;

// AppConstants
@interface AppConstants : NSObject

+ (UIFont *)tableCellTitleFont;
+ (UIFont *)tableCellDetailFont;
+ (UIFont *)buttonFont;
+ (UIFont *)tableSectionTitleFont;
+ (UIFont *)roundedButtonFont;
+ (UIFont *)textFont;
+ (UIFont *)boldTextFont;

+ (UIColor *)navigationBarTintColor;
+ (UIColor *)navigationBarTintColorDarker;
+ (UIColor *)primaryTextColor;
+ (UIColor *)secondaryTextColor;
+ (UIColor *)tableSectionTitleTextColor;
+ (UIColor *)borderColor;

@end
