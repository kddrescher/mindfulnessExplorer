//
//  ViewControllerComposite.h
//

#import <Foundation/Foundation.h>

@class Action;
@class Client;

typedef void (^ActionSelectedBlock)(Action *);

@interface ViewControllerComposite : NSObject

// Properties
@property(nonatomic, retain) Action *action;
@property(nonatomic, retain) Client *client;
@property(nonatomic, retain) NSMutableDictionary *actionBlocks;
@property(nonatomic, assign) UIViewController *viewController;

// Initializers
- (id)initWithClient:(Client *)client viewController:(UIViewController *)viewController;

// Event Handlers
- (void)handleHelpButtonTapped:(id)sender;
- (void)handleModalDismissButtonTapped:(id)sender;

// Instance Methods
- (void)presentModalNavigationControllerWithViewController:(UIViewController *)viewController dismissTitle:(NSString *)dismissTitle;
- (void)setBackButtonTitle:(NSString *)title;

@end
