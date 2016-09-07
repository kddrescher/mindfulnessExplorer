//
//  ActionMenuViewController.m
//

#import "ActionMenuViewController.h"
#import "Action.h"
#import "Client.h"
#import "AppConstants.h"
#import "UIFactory.h"

@implementation ActionMenuViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
  }

  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForActionsWithParent:self.action]];
    [[super fetchedResultsController] setDelegate:self];
  }
  
  return [super fetchedResultsController];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithSubtitleStyleFromTableView:tableView];
  Action *action = [self.fetchedResultsController objectAtIndexPath:indexPath];
  if ([action.accessoryType isEqualToString:kActionAccessoryNone]) {
    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
  }
  
  cell.textLabel.text = action.title;
  cell.detailTextLabel.text = action.details;
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Action *selectedAction = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [self performActionBlockForAction:selectedAction];
}

#pragma mark - Instance Methods

/**
 *  actionWasUpdated
 */
- (void)actionWasUpdated:(Action *)action {
  if (self.action.instructions != nil) {
    UIView *headerView = [UIFactory tableHeaderViewWithText:self.action.instructions
                                                  imageName:nil
                                                      width:self.view.frame.size.width - (kUIViewHorizontalMargin * 2)
                                                     styled:NO];
    
    self.tableView.tableHeaderView = headerView;
  }
}

@end
