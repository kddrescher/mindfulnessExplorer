//
//  TextFieldFormViewController.h
//

#import "FormViewController.h"

@interface TextFieldFormViewController : FormViewController<UITextFieldDelegate>

// Properties
@property(nonatomic, retain) UITableViewCell *tableViewCell;
@property(nonatomic, copy) NSString *initialText;
@property(nonatomic, copy) NSString *placeholderText;

@end
