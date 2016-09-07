//
//  ButtonMenuViewController.m
//  MindfulnessCoach
//

#import "ButtonMenuViewController.h"
#import "Action.h"
#import "AppConstants.h"
#import "RoundedButton.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

@implementation ButtonMenuViewController

#pragma mark - Lifecycle

/**
 *  initWithClient
 */
-(id)initWithClient:(Client *)client {
  self = [super initWithClient:client];
  if (self != nil) {
    _viewLayout = ButtonMenuViewLayoutOneUp;
  }
  
  return self;
}

#pragma mark - Event Handlers

/**
 *  handleMenuButtonWasTouched
 */
- (void)handleMenuButtonWasTouched:(id)sender {
  RoundedButton *button = (RoundedButton *)sender;
  [self performActionBlockForAction:button.action];
}

#pragma mark - Instance Methods

/**
 *  numberOfMenuItems
 */
- (NSUInteger)numberOfMenuItems {
  return [[self.action childrenSortedByRank] count];
}

/**
 *  configureRoundedButton:atIndex
 */
- (void)configureRoundedButton:(RoundedButton *)button atIndex:(NSInteger)index {
  Action *action = [[self.action childrenSortedByRank] objectAtIndex:index];
  button.action = action;
  
  [button setTitle:NSLocalizedString(action.title, nil) forState:UIControlStateNormal];
  [button setImage:[UIImage imageNamed:action.icon] forState:UIControlStateNormal];
}

/**
 *  actionWasUpdated
 */
- (void)actionWasUpdated:(Action *)action {
  [self rebuildMenu];
}

/**
 *  rebuildMenu
 */
- (void)rebuildMenu {
  [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
  scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.alwaysBounceVertical = YES;
  
  // Width and height of background image below.
  CGFloat buttonHeight = (self.viewLayout == ButtonMenuViewLayoutOneUp ? 85.0 : 123.0);
  CGFloat buttonWidth = (self.viewLayout == ButtonMenuViewLayoutOneUp ? 286.0 : 144.0);
  
  CGRect buttonFrame = CGRectMake(kUIViewHorizontalMargin, kUIViewVerticalMargin, buttonWidth, buttonHeight);
  
  if (self.headerView != nil) {
    [scrollView addSubview:self.headerView];
    buttonFrame = CGRectOffset(buttonFrame, 0.0, self.headerView.frame.origin.y + self.headerView.frame.size.height);
  }
  
  if (self.action.instructions != nil) {
    UIView *instructionsView = [UIFactory viewWithText:NSLocalizedString(self.action.instructions, nil)
                                             imageName:nil
                                                 width:self.view.frame.size.width - (kUIViewHorizontalMargin * 2)
                                                styled:NO];
    
    [scrollView addSubview:instructionsView];
    [instructionsView moveToPoint:buttonFrame.origin];
    buttonFrame = CGRectOffset(buttonFrame, 0.0, instructionsView.frame.size.height + kUIViewVerticalMargin);
  }
  
  NSUInteger count = [self numberOfMenuItems];
  for (NSUInteger i = 0; i < count; i++) {
    RoundedButton *button = [[RoundedButton alloc] initWithFrame:buttonFrame];
    [self configureRoundedButton:button atIndex:i];
    
    [button addTarget:self action:@selector(handleMenuButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    
    if (self.viewLayout == ButtonMenuViewLayoutOneUp) {
      [button centerHorizontallyInView:scrollView];
      buttonFrame = CGRectOffset(buttonFrame, 0.0, buttonHeight + kUIViewVerticalMargin);
    } else if (self.viewLayout == ButtonMenuViewLayoutTwoUp) {
      if (i % 2 == 0) {
        [button moveToLeftInParentWithMargin:kUIViewHorizontalMargin];
      } else {
        [button moveToRightInParentWithMargin:kUIViewHorizontalMargin];
        buttonFrame = CGRectOffset(buttonFrame, 0.0, buttonHeight + kUIViewVerticalMargin);
      }
    }
    
    [button release];
  }
  
  [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, buttonFrame.origin.y)];
  [self.view addSubview:scrollView];
  [scrollView release];
}

@end
