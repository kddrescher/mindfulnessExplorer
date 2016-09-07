//
//  BaseViewController.m
//

#import "BaseViewController.h"
#import "AppConstants.h"
#import "ViewControllerComposite.h"

@implementation BaseViewController

#pragma mark - Lifecycle

/**
 *  initWithClient
 */
- (id)initWithClient:(Client *)client {
  self = [self init];
  if (self != nil) {
    _viewControllerComposite = [[ViewControllerComposite alloc] initWithClient:client viewController:self];
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  [self setBackButtonTitle:NSLocalizedString(@"Back", nil)];
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kBackgroundImageNameStripped]];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_viewControllerComposite release];
  
  [super dealloc];
}

#pragma mark - Instance Methods

/**
 *  forwardingTargetForSelector
 */
- (id)forwardingTargetForSelector:(SEL)selector {
  if ([self.viewControllerComposite respondsToSelector:selector]) {
    return self.viewControllerComposite;
  }

  return [super forwardingTargetForSelector:selector];
}

@end
