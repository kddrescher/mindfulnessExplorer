//
//  NotificationFrequencyFormViewController.m
//

#import "NotificationFrequencyFormViewController.h"
#import "NSString+VPDString.h"
#import "UIFactory.h"

@implementation NotificationFrequencyFormViewController

#pragma mark - Lifecycle

/**
 *  dealloc
 */
- (void)dealloc {
  [_frequencies release];
  [_selectedIndexPath release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

- (NSArray *)frequencies {
  if (_frequencies == nil) {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:7];
    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyNone]];
//    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyOneTime]];
    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyDaily]];
//    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyTwicePerDay]];
//    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyThricePerDay]];
//    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyEveryOtherDay]];
    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyWeekly]];
    [items addObject:[NSNumber numberWithInteger:NotificationFrequencyMonthly]];
    
    _frequencies = [items copy];
    [items release];
  }
  
  return _frequencies;
}

/**
 *  fieldValue
 */
- (id)fieldValue {
  return [self.frequencies objectAtIndex:self.selectedIndexPath.row];
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
  return [self.frequencies count];
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  NotificationFrequency frequency = [[self.frequencies objectAtIndex:indexPath.row] integerValue];
  cell.textLabel.text = [NSString stringWithNotificationFrequency:frequency];
    
  if (self.selectedIndexPath != nil && [self.selectedIndexPath compare:indexPath] == NSOrderedSame) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = nil;
  
  if (self.selectedIndexPath != nil) {
    cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  self.selectedIndexPath = indexPath;
  cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Instance Methods

/**
 *  setFrequency
 */
- (void)setFrequency:(NotificationFrequency)frequency {
  NSIndexPath *oldIndexPath = self.selectedIndexPath;
  
  NSNumber *frequencyNumber = [NSNumber numberWithInteger:frequency];
  NSUInteger frequencyIndex = [self.frequencies indexOfObject:frequencyNumber];
  self.selectedIndexPath = [NSIndexPath indexPathForRow:frequencyIndex inSection:0];
  
  if (oldIndexPath != nil) {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
  }
  
  if (self.selectedIndexPath != nil) {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
  }
}

@end
