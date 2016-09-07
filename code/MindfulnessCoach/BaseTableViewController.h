//
//  BaseTableViewController.h
//

#import <UIKit/UIKit.h>
#import "ViewControllerCompositeProtocol.h"

@class Client;
@class ViewControllerComposite;

@interface BaseTableViewController : UITableViewController<ViewControllerCompositeProtocol>

// Properties
@property(nonatomic, retain) NSDateFormatter *dateFormatter;
@property(nonatomic, retain) ViewControllerComposite *viewControllerComposite;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client;

// Instance Methods
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
