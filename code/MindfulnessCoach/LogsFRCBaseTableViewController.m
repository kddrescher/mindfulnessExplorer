//
//  LogsFRCBaseTableViewController.m
//

#import <QuartzCore/QuartzCore.h>
#import "LogsFRCBaseTableViewController.h"
#import "AppConstants.h"
#import "UIView+VPDView.h"

#define kSectionViewHeightDefault 22.0 + kUIViewVerticalMargin
#define kSectionViewHeightSortBar 49.0

@implementation LogsFRCBaseTableViewController

#pragma mark - Lifecycle

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self rebuildTableHeaderAndFooterViews];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

/**
 *  controllerDidChangeContent
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [super controllerDidChangeContent:controller];
  [self rebuildTableHeaderAndFooterViews];
  // Force table to rebuild if there are no more log entries so that we get a chance to hide the sort bar.
  if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
    [self.tableView reloadData];
  }
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:heightForHeaderInSection
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
    return kSectionViewHeightSortBar;
  }
  
  return (self.tableView.style == UITableViewStyleGrouped ?  kSectionViewHeightDefault : 0);
}

/**
 *  tableView:viewForHeaderInSection
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
    UIView *sortBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kSectionViewHeightSortBar)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logEntriesSortBar.png"]];
    imageView.layer.cornerRadius = 4.0;
    imageView.layer.masksToBounds = YES;
    
    [sortBarView addSubview:imageView];
    [imageView moveToLeftInParentWithMargin:kUIViewHorizontalMargin];
    [imageView moveToTopInParent];
    
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sortButton setFrame:CGRectMake(0.0, 0.0, 90.0, 44.0)];
    [sortButton setImage:[UIImage imageNamed:@"logEntriesSortBarSortByDate"] forState:UIControlStateNormal];
    [sortButton setImage:[UIImage imageNamed:@"logEntriesSortBarSortByDescriptor"] forState:UIControlStateSelected];
    [sortButton addTarget:self action:@selector(handleSortBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [sortButton setSelected:self.sortBySecondary];
    [sortBarView addSubview:sortButton];
    [sortButton moveToTopInParentWithMargin:3.0];
    [sortButton moveToLeftInParentWithMargin:kUIViewHorizontalMargin * 2];
    
    UIButton *newEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newEntryButton setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [newEntryButton setImage:[UIImage imageNamed:@"logEntriesSortBarAdd"] forState:UIControlStateNormal];
    [newEntryButton addTarget:self action:@selector(handleCreateLogEntryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [sortBarView addSubview:newEntryButton];
    [newEntryButton moveToTopInParentWithMargin:3.0];
    [newEntryButton moveToRightInParentWithMargin:kUIViewHorizontalMargin * 2];
    
    if (self.tableView.style == UITableViewStylePlain) {
      sortBarView.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
      
      [sortButton setImage:[UIImage imageNamed:@"logEntriesSortBarSortByDateAsc"] forState:UIControlStateNormal];
      [sortButton setImage:[UIImage imageNamed:@"logEntriesSortBarSortByDateDesc"] forState:UIControlStateSelected];
      [sortButton moveToLeftInParentWithMargin:kUIViewHorizontalMargin];
      [newEntryButton moveToRightInParentWithMargin:kUIViewHorizontalMargin];
    }
    
    [imageView release];
    
    return [sortBarView autorelease];
  }
  
  return nil;
}

#pragma mark - Message Handlers

/**
 *  handleCreateLogEntryButtonTapped
 */
- (void)handleCreateLogEntryButtonTapped:(id)sender {
  // Intentionally left blank.
}

/**
 *  handleSortBarButtonTapped
 */
- (void)handleSortBarButtonTapped:(id)sender {
  self.sortBySecondary = !self.sortBySecondary;
  [(UIButton *)sender setSelected:self.sortBySecondary];
  self.fetchedResultsController = nil;
  [self.tableView reloadData];
}

#pragma mark - Instance Methods

/**
 *  rebuildTableHeaderAndFooterViews
 */
- (void)rebuildTableHeaderAndFooterViews {
  // Intentionally left blank.
}

@end
