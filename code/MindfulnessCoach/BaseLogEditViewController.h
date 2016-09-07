//
//  BaseLogEditViewController.h
//

#import <MessageUI/MessageUI.h>
#import "BaseEditViewController.h"

@class EmailBuilder;

@interface BaseLogEditViewController : BaseEditViewController<MFMailComposeViewControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate>

// Properties
@property(nonatomic, assign, getter = isEditingExistingLogEntry) BOOL editingExistingLogEntry;
@property(nonatomic, strong) EmailBuilder *emailBuilder;

@end
