//
//  FRCBaseTableViewController.h
//

#import "BaseTableViewController.h"

@interface FRCBaseTableViewController : BaseTableViewController<NSFetchedResultsControllerDelegate>

// Properties
@property(nonatomic, assign, readonly) NSUInteger prefixedSectionsCount;
@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// Instance Methods
- (NSIndexPath *)normalizeIndexPath:(NSIndexPath *)indexPath;

@end
