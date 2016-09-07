//
//  BaseViewController.h
//

#import <UIKit/UIKit.h>
#import "ViewControllerCompositeProtocol.h"

@class Client;
@class ViewControllerComposite;

@interface BaseViewController : UIViewController<ViewControllerCompositeProtocol>

// Properties
@property(nonatomic, retain) ViewControllerComposite *viewControllerComposite;

// Initializers
- (id)initWithClient:(Client *)client;

@end
