//
//  BlackoutEditViewController.h
//

#import "BaseEditViewController.h"

@class Blackout;

enum {
  kBlackoutEditViewRowStartDate = 0,
  kBlackoutEditViewRowEndDate
};

@interface BlackoutEditViewController : BaseEditViewController

// Properties
@property(nonatomic, retain) UIDatePicker *datePicker;
@property(nonatomic, retain, readonly) Blackout *blackout;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client blackout:(Blackout *)blackout;

// Event Handlers
- (void)handleDatePickerValueChanged:(id)sender;

@end
