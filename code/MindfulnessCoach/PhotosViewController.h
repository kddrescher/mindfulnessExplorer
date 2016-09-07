//
//  PhotosViewController.h
//

#import "FRCBaseTableViewController.h"

@interface PhotosViewController : FRCBaseTableViewController<UINavigationControllerDelegate,
                                                             UIImagePickerControllerDelegate>

// Message Handlers
- (void)handleAddButtonTapped:(id)sender;

@end
