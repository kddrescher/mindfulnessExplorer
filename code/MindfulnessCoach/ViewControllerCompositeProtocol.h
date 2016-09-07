//
//  ViewControllerCompositeProtocol.h
//

#import <Foundation/Foundation.h>

@class Action;
@class Client;

/**
  * This class really just exists to suppress compiler warnings. Without it, our view
  * controllers would have to call [self performSelector:...] to prevent the compiler
  * from generating warnings for method calls that will ultimately get forwarded to the
  * view controller composite object.
  */

@protocol ViewControllerCompositeProtocol <NSObject>

@optional

@property(nonatomic, retain) Action *action;
@property(nonatomic, retain) Client *client;


- (void)presentModalNavigationControllerWithViewController:(UIViewController *)viewController dismissTitle:(NSString *)dismissTitle;
- (void)performActionBlockForAction:(Action *)action;
- (void)setBackButtonTitle:(NSString *)title;

@end
