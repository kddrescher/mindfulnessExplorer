//
//  SettingsViewController.h
//

#import "BaseTableViewController.h"

enum {
  kTableViewSectionApplicationVersion = 0,
  kTableViewSectionAnalytics,
  kTableViewSectionResetUserData,
  NUM_TABLE_VIEW_SECTIONS_FOR_SETTINGS
};

@interface SettingsViewController : BaseTableViewController<UIActionSheetDelegate>

@end
