//
//  FormViewController.m
//

#import "FormViewController.h"

@implementation FormViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    _popViewControllerOnCancel = YES;
    _popViewControllerOnDone = YES;
    
    // Set up the navigation items.
    self.navigationItem.title = NSLocalizedString(_fieldTitle, nil);
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self 
                                                                                      action:@selector(handleCancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(handleDoneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    [doneButtonItem release];
  }
  
  return self;
}

/**
 *  initWithStyle:client:fieldTitle
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client fieldTitle:(NSString *)fieldTitle {
  self = [self initWithStyle:style client:client];
  if (self != nil) {
    _fieldTitle = [fieldTitle copy];
    
    self.navigationItem.title = fieldTitle;
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(handleKeyboardWillShowNotification:) 
                                               name:UIKeyboardWillShowNotification 
                                             object:nil];
}

/**
 *  viewDidUnload
 */
- (void)viewDidUnload {
  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:UIKeyboardWillShowNotification 
                                                object:nil];
  
  [super viewDidUnload];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_fieldTitle release];
  [_fieldValue release];
  [_doneBlock release];
  [_cancelledBlock release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  fieldValue
 */
- (id)fieldValue {
  // Derived classes are expected to implement their own accessor.
  return nil;
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
  return 1;
}

#pragma mark - Event Handlers

/**
 *  handleCancelButtonTapped
 */
- (void)handleCancelButtonTapped:(id)sender; {
  if (self.cancelledBlock != nil) {
    self.cancelledBlock();
  }
  
  if (self.shouldPopViewControllerOnCancel) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

/**
 *  handleDoneButtonTapped
 */
- (void)handleDoneButtonTapped:(id)sender {
  if (self.doneBlock != nil) {
    self.doneBlock(self.fieldValue);
  }

  if (self.shouldPopViewControllerOnDone) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

/**
 *  handleKeyboardWillShowNotification
 */
- (void)handleKeyboardWillShowNotification:(NSNotification*)notification {
  // Intentionally left blank.
}

/**
 *  handleKeyboardWillHideNotification
 */
- (void)handleKeyboardWillHideNotification:(NSNotification*)notification {
  // Intentionally left blank.
}

@end
