//
//  FormViewController.h
//

#import "BaseTableViewController.h"

@class Client;

typedef void (^FormViewDoneBlock)(id);
typedef void (^FormViewCancelledBlock)(void);

// FormViewController
@interface FormViewController : BaseTableViewController

// Properties
@property(nonatomic, copy, readonly) NSString *fieldTitle;
@property(nonatomic, retain) id fieldValue;
@property(nonatomic, copy) FormViewDoneBlock doneBlock;
@property(nonatomic, copy) FormViewCancelledBlock cancelledBlock;
@property(nonatomic, assign, getter = shouldPopViewControllerOnCancel) BOOL popViewControllerOnCancel;
@property(nonatomic, assign, getter = shouldPopViewControllerOnDone) BOOL popViewControllerOnDone;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client fieldTitle:(NSString *)fieldTitle;

// Event Handlers
- (void)handleCancelButtonTapped:(id)sender;
- (void)handleDoneButtonTapped:(id)sender;

- (void)handleKeyboardWillShowNotification:(NSNotification*)notification;
- (void)handleKeyboardWillHideNotification:(NSNotification*)notification;

@end
