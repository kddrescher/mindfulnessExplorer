//
//  RoundedButton.h
//

#import <UIKit/UIKit.h>

@class Action;

@interface RoundedButton : UIButton

// Properties
@property(nonatomic, strong) Action *action;
@property(nonatomic, strong) id<NSObject> userInfo;

@end
