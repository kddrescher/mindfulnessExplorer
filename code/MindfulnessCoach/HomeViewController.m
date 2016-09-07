//
//  HomeViewController.m
//  MindfulnessCoach
//

#import "HomeViewController.h"
#import "AppConstants.h"
#import "ButtonMenuViewController.h"
#import "Client.h"
#import "RoundedButton.h"
#import "UIView+VPDView.h"

@implementation HomeViewController

#pragma mark - Lifecycle

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *aboutButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(handleAboutButtonTouched:)];
  self.navigationItem.leftBarButtonItem = aboutButtonItem;
  [aboutButtonItem release];
}

#pragma mark - Event Handlers

/**
 *  handleMenuButtonWasTouched
 */
- (void)handleMenuButtonWasTouched:(id)sender {
  RoundedButton *button = (RoundedButton *)sender;
  [self performActionBlockForAction:button.action];
}

/**
 *  handleAboutButtonTouched
 */
- (void)handleAboutButtonTouched:(id)sender {
  ButtonMenuViewController *aboutMenuViewController = [[ButtonMenuViewController alloc] initWithClient:self.client];
  aboutMenuViewController.action = [self.client rootActionForGroup:kActionGroupAbout];
  
  [self.navigationController pushViewController:aboutMenuViewController animated:YES];
  
  [aboutMenuViewController release];
}

@end
