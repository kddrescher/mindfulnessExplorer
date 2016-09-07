//
//  DateFormViewController.h
//

#import "FormViewController.h"

@interface DateFormViewController : FormViewController

// Properties
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSDate *maximumDate;
@property(nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic, assign) UIDatePickerMode datePickerMode;

// Event Handlers
- (void)handleDatePickerValueChanged:(id)sender;

@end
