//
//  AppConstants.m
//
//  This file is partially shared across several applications. As such, not all 
//  of the constants defined here are necessarily used in this application. 

#import "AppConstants.h"

#pragma mark - Application

NSString *const kApplicationContentPath = @"MindfulnessCoachContent.xml";
NSString *const kFlurryAnalyticsAPIKey = @"JZC8GWVZA1F3LCXTG5WF";
NSString *const kTestFlightAppToken = @"9f807c7e-36a1-4e2e-a826-b37f188564df";

#pragma mark - Action Accessories

NSString *const kActionAccessoryNone = @"none";

#pragma mark - Action groups

NSString *const kActionGroupHome = @"home";
NSString *const kActionGroupLearn = @"learn";
NSString *const kActionGroupPractice = @"practice";
NSString *const kActionGroupTrack = @"track";
NSString *const kActionGroupRemind = @"remind";
NSString *const kActionGroupAbout = @"about";

#pragma mark - Action Types

NSString *const kActionTypeButtonMenu = @"buttonMenu";
NSString *const kActionTypeDismissAndSetTabIndex = @"dismissAndSetTabIndex";
NSString *const kActionTypeMenu = @"menu";
NSString *const kActionTypePage = @"page";
NSString *const kActionTypeRoot = @"root";

NSString *const kActionTypeEditActivity = @"editActivity";
NSString *const kActionTypeViewActivities = @"viewActivities";
NSString *const kActionTypeViewActivityProgress = @"viewActivityProgress";

NSString *const kActionTypeEditExerciseEvent = @"editExerciseEvent";
NSString *const kActionTypeEditRandomReminders = @"editRandomReminders";
NSString *const kActionTypeEditLogReminder = @"editLogReminder";

NSString *const kActionTypeShowSettings = @"showSettings";

#pragma mark - Content

NSString *const kContentHTMLLayoutPath = @"layout.html";
NSString *const kContentHTMLLayoutPlaceholder = @"__PAGE_CONTENT__";
NSString *const kContentHTMLBodyClassPlaceholder = @"__BODY_CLASS__";

NSString *const kContentHTMLURLViewIntroductionScreen = @"viewIntroductionScreen.vpd";
NSString *const kContentHTMLURLViewHomeScreen = @"viewHomeScreen.vpd";
NSString *const kContentHTMLURLGoToAction = @"gotoAction.vpd";
NSString *const kContentHTMLURLGoToPage = @"gotoPage.vpd";
NSString *const kContentHTMLURLPlayVideo = @"playVideo.vpd";
NSString *const kContentHTMLURLNewActivity = @"newActivity.vpd";
NSString *const kContentHTMLURLViewSongsController = @"viewSongsController.vpd";
NSString *const kContentHTMLURLViewPhotosController = @"viewPhotosController.vpd";
NSString *const kContentHTMLURLViewPracticePhotosController = @"viewPracticePhotosController.vpd";
NSString *const kContentHTMLURLViewPracticeSongsController = @"viewPracticeSongsController.vpd";
NSString *const kContentHTMLURLViewPracticeEnvironmentController = @"viewPracticeEnvironmentController.vpd";

NSString *const kContentHTMLURLLegalEULA = @"legalEULA.html";
NSString *const kContentHTMLURLLegalIntroduction = @"legalIntroduction.html";

#pragma mark - Images

NSString *const kBackgroundImageNameStripped = @"backgroundGrayStripped.png";

#pragma mark - UILocalNotifications

NSString *const kLocalNotificationTypeKey = @"reminderType";
NSString *const kLocalNotificationTypeRandomReminder = @"randomReminder";
NSString *const kLocalNotificationTypeLogReminder = @"logReminder";

#pragma mark - User Defaults Keys

NSString *const kUserDefaultsKeyContentVersion = @"gov.va.mindfulnesscoach.contentVersion";
NSString *const kUserDefaultsKeyViewedLegalScreens = @"gov.va.mindfulnesscoach.viewedLegalScreens";
NSString *const kUserDefaultsKeyRecordUsageData = @"gov.va.mindfulnesscoach.recordUsageData";

#pragma mark - UIKit

NSInteger const kViewTagTableViewCellTextField = 100;
NSInteger const kViewTagTableViewCellLabelDate = 101;
NSInteger const kViewTagTableViewCellLabelAudio = 102;
NSInteger const kViewTagTableViewCellLabelDuration = 103;
NSInteger const kViewTagTableViewCellLabelTitle = 104;
NSInteger const kViewTagTableViewCellLabelComments = 105;
NSInteger const kViewTagTableViewCellShadowTextField = 106;
NSInteger const kViewTagTableViewCellTextView = 107;
NSInteger const kViewTagTableViewFooterButton = 108;
NSInteger const kViewTagTableViewHeaderLabel = 109;
NSInteger const kViewTagTableViewCellVariableHeightLabel = 110;

CGFloat const kUIHeightButton = 37.0;
CGFloat const kUIHeightDatePicker = 216.0;
CGFloat const kUIHeightKeyboard = 216.0;
CGFloat const kUIHeightTextField = 31.0;
CGFloat const kUIHeightToolbar = 44.0;
CGFloat const kUIHeightTableViewCellWithTextView = 178.0;

CGFloat const kUIHeightRoundSwitch = 27.0;
CGFloat const kUIWidthRoundSwitch = 80.0;

CGFloat const kUIViewVerticalMargin = 10.0;
CGFloat const kUIViewHorizontalMargin = 10.0;

#pragma mark - AppConstants

@implementation AppConstants

/**
 *  tableCellTitleFont
 */
+ (UIFont *)tableCellTitleFont {
  return [UIFont boldSystemFontOfSize:15.0];
}

/**
 *  tableCellFont
 */
+ (UIFont *)tableCellDetailFont {
  return [UIFont systemFontOfSize:15.0];
}

/**
 *  buttonFont
 */
+ (UIFont *)buttonFont {
  return [UIFont boldSystemFontOfSize:17.0];
}


/**
 *  tableSectionTitleFont
 */
+ (UIFont *)tableSectionTitleFont {
  return [AppConstants textFont];
}

/**
 *  roundedButtonFont
 */
+ (UIFont *)roundedButtonFont {
  return [UIFont boldSystemFontOfSize:15.0];
}

/**
 *  textFont
 */
+ (UIFont *)textFont {
  return [UIFont systemFontOfSize:15.0];
}

/**
 *  boldTextFont
 */
+ (UIFont *)boldTextFont {
  return [UIFont boldSystemFontOfSize:15.0];
}

/**
 *  navigationBarTintColor
 */
+ (UIColor *)navigationBarTintColor {
  return [UIColor colorWithRed:85.0/255.0 green:140.0/255.0 blue:89.0/255.0 alpha:1.000];
}

/**
 *  navigationBarTintColorDarker
 */
+ (UIColor *)navigationBarTintColorDarker {
  return [UIColor colorWithRed:0.098 green:0.250 blue:0.479 alpha:1.000];
}

/**
 *  primaryTextColor
 */
+ (UIColor *)primaryTextColor {
  return [UIColor colorWithRed:28.0/255.0 green:39.0/255.0 blue:57.0/255.0 alpha:1.0];
}

/**
 *  secondaryTextColor
 */
+ (UIColor *)secondaryTextColor {
  return [UIColor colorWithRed:0.149 green:0.314 blue:0.576 alpha:1.000];
}

/**
 *  tableSectionTitleTextColor
 */
+ (UIColor *)tableSectionTitleTextColor {
  return [UIColor colorWithRed:11.0/255.0 green:15.0/255.0 blue:20.0/255.0 alpha:1.0];
}

/**
 *  borderColor
 */
+ (UIColor *)borderColor {
  return [UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0];
}

@end
