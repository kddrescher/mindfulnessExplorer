//
//  LogsFRCBaseTableViewController.h
//

#import "FRCBaseTableViewController.h"

@interface LogsFRCBaseTableViewController : FRCBaseTableViewController

// Properties
@property(nonatomic, assign, getter = isSortBySecondary) BOOL sortBySecondary;

// Instance Methods
- (void)rebuildTableHeaderAndFooterViews;

@end
