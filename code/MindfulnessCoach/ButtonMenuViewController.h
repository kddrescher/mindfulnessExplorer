//
//  ButtonMenuViewController.h
//  MindfulnessCoach
//

#import "BaseViewController.h"

@class RoundedButton;

typedef NS_ENUM(NSUInteger, ButtonMenuViewLayout) {
  ButtonMenuViewLayoutOneUp = 0,
  ButtonMenuViewLayoutTwoUp = 1
};

@interface ButtonMenuViewController : BaseViewController

// Properties
@property(nonatomic, assign) ButtonMenuViewLayout viewLayout;
@property(nonatomic, strong) UIView *headerView;

// Instance Methods
- (NSUInteger)numberOfMenuItems;
- (void)configureRoundedButton:(RoundedButton *)button atIndex:(NSInteger)index;
- (void)rebuildMenu;

@end
