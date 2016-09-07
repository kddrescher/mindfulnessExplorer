//
//  DateFormViewController.m
//

#import "DateFormViewController.h"
#import "AppConstants.h"
#import "NSString+VPDString.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

@implementation DateFormViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client:fieldTitle
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client fieldTitle:(NSString *)fieldTitle {
  self = [super initWithStyle:style client:client fieldTitle:fieldTitle];
  if (self != nil) {
    _date = [[NSDate alloc] init];
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];

  // Instead of the default UIKeyboard, we use a UIDatePicker as the input view.
  UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
  datePicker.datePickerMode = self.datePickerMode;
  if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
    [datePicker setDate:[self setDateFromSeconds:self.timeInterval] animated:true];
  } else {
    datePicker.date = self.date;
    datePicker.maximumDate = self.maximumDate;
  }
  
  [datePicker addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
  
  // This is a hidden text field that the user never sees. However, by using it we can leverage the fact
  // that a UITableViewController knows how to handle the showing and hiding of an input view and properly
  // scrolling the table view so that the appropriate table cell is visibile.
  UITextField *shadowTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  shadowTextField.hidden = YES;
  shadowTextField.inputView = datePicker;

  self.tableView.tableFooterView = shadowTextField;
  
  [datePicker release];
  [shadowTextField release];
}

- (NSDate*) setDateFromSeconds:(double)seconds {
    NSUInteger intSeconds = (NSUInteger)seconds;
    NSUInteger minutes = (intSeconds / 60) % 60;
    NSUInteger hours = intSeconds / 3600;
    NSString* dateString = [NSString stringWithFormat:@"%0.2d:%0.2d", hours, minutes];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"hh:mm";
    return [dateFormatter dateFromString:dateString];
}

/**
 *  viewWillAppear
 */
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Make the text fiew the first responder so that the UIDatePicker is already visible
  // by the time this screen is shown to the user.
  UITextField *shadowTextField = (UITextField *)self.tableView.tableFooterView;
  [shadowTextField becomeFirstResponder];
}

/**
 *  dealloc
 */
- (void)dealloc {  
  [_date release];
  [_maximumDate release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  fieldValue
 */
- (id)fieldValue {
  if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
    return [NSNumber numberWithDouble:self.timeInterval];
  }

  return self.date;
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDetailStyleFromTableView:tableView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;

  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:heightForHeaderInSection
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  // Since we only have one section, we can use this method to add some additional height to the
  // default section so that our single row is vertically centered in the table view.
  return (tableView.frame.size.height - tableView.rowHeight - kUIHeightKeyboard) / 2;
}

#pragma mark - Event Handlers

/**
 *  handleDatePickerValueChanged
 */
- (void)handleDatePickerValueChanged:(id)sender {
  UIDatePicker *datePicker = (UIDatePicker *)sender;
  if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
    self.timeInterval = datePicker.countDownDuration;
  } else {
    self.date = datePicker.date;
  }
  
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
}

#pragma mark - Instance Methods

/**
 *  configureCell:atIndexPath
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  cell.textLabel.text = self.fieldTitle;
  
  switch (self.datePickerMode) {
    case UIDatePickerModeTime: {
      self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
      self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
      
      cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.date];
      break;
    }
      
    case UIDatePickerModeDate: {
      self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
      self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
      
      cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.date];
      break;
    }
      
    case UIDatePickerModeDateAndTime: {
      self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
      self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
      
      cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.date];
      break;
    }
      
    case UIDatePickerModeCountDownTimer: {
      cell.detailTextLabel.text = [NSString stringWithTimeInterval:self.timeInterval];
      break;
    }
  }
}

@end
