//
//  FRCFormViewController.m
//

#import "FRCFormViewController.h"
#import "Client.h"
#import "UIFactory.h"

@implementation FRCFormViewController

#pragma mark - Lifecycle

/**
 *  dealloc
 */
- (void)dealloc {
  [_fetchedResultsController release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  setFetchedResultsController
 */
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != fetchedResultsController) {
    [_fetchedResultsController release];
    _fetchedResultsController = [fetchedResultsController retain];
    
    if ([_fetchedResultsController delegate] == nil) {
      [_fetchedResultsController setDelegate:self];
    }
  }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

/**
 *  controllerDidChangeContent
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView reloadData];
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
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Intentionally left blank.
}

@end