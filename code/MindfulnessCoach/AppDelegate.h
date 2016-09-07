//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class Client;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Properties
@property(nonatomic, retain) UITabBarController *tabBarController;
@property(nonatomic, retain) UIWindow *window;
@property(nonatomic, retain) Client *client;

// Instance Methods
- (void)clearUserDataAndResetApplicationState;

@end
