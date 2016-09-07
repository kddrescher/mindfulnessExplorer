//
//  TextViewFormViewController.m
//

#import "TextViewFormViewController.h"
#import "AppConstants.h"
#import "UIFactory.h"

@implementation TextViewFormViewController

#pragma mark - Lifecycle

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.scrollEnabled = NO;
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
  
  UITextView *textView = (UITextView *)[self.tableViewCell viewWithTag:kViewTagTableViewCellTextView];
  [textView becomeFirstResponder];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_tableViewCell release];
  [_initialText release];

  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  tableViewCell
 */
- (UITableViewCell *)tableViewCell {
  // We're creating our tableViewCell as a property here instead of in the more common
  // tableView:cellForRowAtIndexPath so that we can access the UITextView and make it
  // the first responder before the view is shown, which happens before cellForRow...
  // is called.
  if (_tableViewCell == nil) {
    _tableViewCell = [[UIFactory cellWithTextViewFromTableView:self.tableView] retain];
    UITextView *textView = (UITextView *)[[_tableViewCell contentView] viewWithTag:kViewTagTableViewCellTextView];
    textView.text = _initialText;
  }
  
  return _tableViewCell;
}

/**
 *  fieldValue
 */
- (id)fieldValue {
  UITextView *textView = (UITextView *)[self.tableViewCell viewWithTag:kViewTagTableViewCellTextView];

  return textView.text;
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
 *  tableView:heightForRowAtIndexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // Magic height that takes the UIKeyboard height in to account.
  return kUIHeightTableViewCellWithTextView;
}

@end
