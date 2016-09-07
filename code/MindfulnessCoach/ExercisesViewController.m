//
//  ExercisesViewController.m
//

#import "ExercisesViewController.h"
#import "Client.h"
#import "Exercise.h"
#import "ExerciseViewController.h"
#import "UIFactory.h"

@implementation ExercisesViewController

#pragma mark - Properties

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

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForExercises]];
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
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Exercise *selectedExercise = (Exercise *)[self.fetchedResultsController objectAtIndexPath:indexPath];
  ExerciseViewController *exerciseViewController = [[ExerciseViewController alloc] initWithClient:self.client exercise:selectedExercise];
  [self.navigationController pushViewController:exerciseViewController animated:YES];
  [exerciseViewController release];
}

#pragma mark - Instance Methods

/**
 *  configureCell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Exercise *exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = exercise.title;
}

@end
