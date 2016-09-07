//
//  TextFieldFormViewController.m
//

#import "TextFieldFormViewController.h"
#import "AppConstants.h"
#import "UIFactory.h"

@implementation TextFieldFormViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    // TextField forms don't have a 'Done' button because they already have one on the keyboard.
    self.navigationItem.rightBarButtonItem = nil;
  }
  
  return self;
}

/**
 *  viewDidUnload
 */
- (void)viewDidUnload {
  self.tableViewCell = nil;
  
  [super viewDidUnload];
}

/**
 *  viewWillAppear
 */
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UITextField *textField = (UITextField *)[self.tableViewCell viewWithTag:kViewTagTableViewCellTextField];
  [textField becomeFirstResponder];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_tableViewCell release];
  [_initialText release];
  [_placeholderText release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  tableViewCell
 */
- (UITableViewCell *)tableViewCell {
  // See note in TextViewFormViewController.m
  if (_tableViewCell == nil) {
    _tableViewCell = [[UIFactory cellWithTextFieldFromTableView:self.tableView] retain];
    UITextField *textField = (UITextField *)[[_tableViewCell contentView] viewWithTag:kViewTagTableViewCellTextField];
    textField.placeholder = _placeholderText;
    textField.text = _initialText;
    textField.delegate = self;
  }
  
  return _tableViewCell;
}

/**
 *  fieldValue
 */
- (id)fieldValue {
  UITextField *textField = (UITextField *)[self.tableViewCell viewWithTag:kViewTagTableViewCellTextField];
  return textField.text;
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.tableViewCell;
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

#pragma mark - UITextFieldDelegate Methods

/**
 *  textFieldShouldReturn
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [super handleDoneButtonTapped:nil];
  return YES;
}

@end
