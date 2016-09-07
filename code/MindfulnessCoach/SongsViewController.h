//
//  SongsViewController.h
//

#import <MediaPlayer/MediaPlayer.h>
#import "FRCBaseTableViewController.h"

@interface SongsViewController : FRCBaseTableViewController<MPMediaPickerControllerDelegate>

// Message Handlers
- (void)handleAddButtonTapped:(id)sender;

@end
