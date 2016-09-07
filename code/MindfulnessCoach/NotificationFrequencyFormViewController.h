//
//  NotificationFrequencyFormViewController.h
//

#import "FormViewController.h"
#import "AppConstants.h"

@interface NotificationFrequencyFormViewController : FormViewController

// Properties
@property(nonatomic, retain) NSArray *frequencies;
@property(nonatomic, retain) NSIndexPath *selectedIndexPath;
@property(nonatomic, assign) NotificationFrequency displayedFrequencies;

// Instance Methods
- (void)setFrequency:(NotificationFrequency)frequency;

@end
