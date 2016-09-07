//
//  BlackoutEditViewController.m
//

#import "BlackoutEditViewController.h"
#import "Blackout.h"
#import "Client.h"
#import "NSDate+VPDDate.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

#define kBlackoutShadowKeyStartDate @"startDate"
#define kBlackoutShadowKeyEndDate @"endDate"

@implementation BlackoutEditViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client:blackout
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client blackout:(Blackout *)blackout {
  self = [self initWithStyle:style client:client managedObject:blackout];
  if (self != nil) {
    self.navigationItem.title = NSLocalizedString(@"Times Not To Alert", nil);
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.scrollEnabled = NO;
  
  UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
  datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  datePicker.datePickerMode = UIDatePickerModeTime;
  
  [datePicker addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
  
  [self.view addSubview:datePicker];
  [datePicker moveToBottomInParent];
  
  self.datePicker = datePicker;
  [datePicker release];
}

/**
 *  viewDidAppear
 */
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_datePicker release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  scratchObjectEntityName
 */
- (NSString *)scratchObjectEntityName {
  return @"Blackout";
}

/**
 *  blackout
 */
- (Blackout *)blackout {
  return (Blackout *)(self.scratchObject);
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDetailStyleFromTableView:tableView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == kBlackoutEditViewRowStartDate) {
    [self.datePicker setDate:self.blackout.startDate animated:YES];
  } else if (indexPath.row == kBlackoutEditViewRowEndDate) {
    [self.datePicker setDate:self.blackout.endDate animated:YES];
  }
}

#pragma mark - Event Handlers

/**
 *  handleDoneButtonTapped
 */
/*
- (void)handleDoneButtonTapped:(id)sender {
  NSDate *startDate = self.blackout.startDate;
  NSDate *endDate = self.blackout.endDate;
  
  if ([endDate isBeforeDate:startDate]) {
    NSString *alertTitle = NSLocalizedString(@"Invalid Times", nil);
    NSString *alertMessage = NSLocalizedString(@"The end time must be after the start time.", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
  } else {
    [super handleDoneButtonTapped:sender];
  }
}
*/
/**
 *  handleDatePickerValueChanged
 */
- (void)handleDatePickerValueChanged:(id)sender {
  NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
  UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
  
  if (selectedIndexPath.row == kBlackoutEditViewRowStartDate) {
    self.blackout.startDate = self.datePicker.date;
  } else if (selectedIndexPath.row == kBlackoutEditViewRowEndDate) {
    self.blackout.endDate = self.datePicker.date;
  }
  
  [self configureCell:selectedCell atIndexPath:selectedIndexPath];
}

#pragma mark - Instance Methods

/**
 *  configureCell:atIndexPath
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
  self.dateFormatter.timeStyle = NSDateFormatterShortStyle;

  if (indexPath.row == 0) {
    cell.textLabel.text = NSLocalizedString(@"Start", nil);
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.blackout.startDate];
  } else if (indexPath.row == 1) {
    cell.textLabel.text = NSLocalizedString(@"End", nil);
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.blackout.endDate];
  }
}

/**
 *  populateDefaultValuesWithNewManagedObject
 */
- (void)populateDefaultValuesWithNewManagedObject:(NSManagedObject *)managedObject {
  self.blackout.startDate = [NSDate date];
  self.blackout.endDate = [[NSDate date] dateByAddingHours:1];
}

@end
