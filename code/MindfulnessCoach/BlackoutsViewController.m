//
//  BlackoutsViewController.m
//

#import "BlackoutsViewController.h"
#import "Blackout.h"
#import "BlackoutEditViewController.h"
#import "Client.h"
#import "AppConstants.h"
#import "UIFactory.h"

@implementation BlackoutsViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    self.navigationItem.title = NSLocalizedString(@"Times Not To Alert", nil);
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                               target:self 
                                                                               action:@selector(handleAddBlackoutButtonTapped:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
  }
  
  return self;
}

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForBlackouts]];
    [[super fetchedResultsController] setDelegate:self];
  }
  
  return [super fetchedResultsController];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:editingStyleForRowAtIndexPath
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

/**
 *  tableView:commitEditingStyle:forRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Blackout *blackout = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.client deleteObject:blackout];
  }
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
 [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // We don't allow editing of existing Blackouts since they are so easily deleted and created.
}

#pragma mark - Instance Methods

/**
 *  configureCell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Blackout *blackout = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
  self.dateFormatter.timeStyle = NSDateFormatterShortStyle;

  NSString *timestamp = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"From", nil),
                                                                [self.dateFormatter stringFromDate:blackout.startDate], 
                                                                NSLocalizedString(@"to", nil),
                                                                [self.dateFormatter stringFromDate:blackout.endDate]];
  
  cell.textLabel.text = timestamp;
}

#pragma mark - Event Handlers

/**
 *  handleAddBlackoutButtonTapped
 */
- (void)handleAddBlackoutButtonTapped:(id)sender {
  BlackoutEditViewController *editViewController = [[BlackoutEditViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                              client:self.client 
                                                                                            blackout:nil];
  
  UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
  modalNavigationController.navigationBar.tintColor = [AppConstants navigationBarTintColor];
  [self presentViewController:modalNavigationController animated:YES completion:nil];
  
  [modalNavigationController release];
  [editViewController release];
}

@end
