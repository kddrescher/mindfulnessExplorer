//
//  BaseTableViewController.m
//

#import "BaseTableViewController.h"
#import "AppConstants.h"
#import "ViewControllerComposite.h"

@implementation BaseTableViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style];
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
  
  if (self.tableView.style == UITableViewStyleGrouped) {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBackgroundImageNameStripped]];
    self.tableView.backgroundView = backgroundView;
    [backgroundView release];
  }
}

/**
 *  viewDidUnload
 */
- (void)viewDidUnload {
  self.dateFormatter = nil;
  
  [super viewDidUnload];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_dateFormatter release];
  [_viewControllerComposite release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  dateFormatter
 */
- (NSDateFormatter *)dateFormatter {
  if (_dateFormatter == nil) {
    _dateFormatter = [[NSDateFormatter alloc] init];
  }
  
  return _dateFormatter;
}

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // Derived classes are expected to provide their own implementation.
  return nil;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Intentionally left blank.
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

/**
 *  configureCell:atIndexPath
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  // Intentionally left blank.
}

@end
