//
//  PhotosViewController.m
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "PhotosViewController.h"
#import "Client.h"
#import "Photo.h"
#import "UIFactory.h"

#define THUMBNAIL_WIDTH 75
#define THUMBNAIL_HEIGHT 75
#define THUMBNAIL_MARGIN 4

@implementation PhotosViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:UITableViewStylePlain client:client];
  if (self != nil) {
    self.navigationItem.title = NSLocalizedString(@"Soothing Photos", nil);
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(handleAddButtonTapped:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    [addButtonItem release];
  }
  
  return self;
}

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForPhotos]];
    [[super fetchedResultsController] setDelegate:self];
  }
  
  return [super fetchedResultsController];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:editingStyleForRowAtIndexPath
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return (THUMBNAIL_HEIGHT + THUMBNAIL_MARGIN);
}

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Intentionally left blank.
}

#pragma mark - UIImagePickerControllerDelegate Methods

/**
 *  imagePickerController:didFinishPickingMediaWithInfo
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [self dismissViewControllerAnimated:YES completion:nil];

  if ([[self.fetchedResultsController fetchedObjects] count] >= 20) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Maximum Photos Reached.", nil)
                                                        message:NSLocalizedString(@"You have reached the maximum photo count of 20. "
                                                                                  "Please remove existing photos from your list before "
                                                                                  "attempting to add new ones.", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
  } else {
    // Core Data best-practices highly recommend not storing large binary data in an entity. We're living
    // dangerously here folks. Ideal, we'd store the image data in a local file under our application, or
    // just rely on the reference URL for loading the image from the user's camera roll. (Only problem there
    // is that if the user deletes the image, then it's gone from our app. That may, or may not, be desired.)
    NSURL *referenceURL = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:referenceURL 
                   resultBlock:^(ALAsset *asset) {
                     UIImage *thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                     
                     NSMutableDictionary *photoAttributes = [[NSMutableDictionary alloc] initWithCapacity:4];
                     [photoAttributes setValue:referenceURL.absoluteString forKey:@"referencePath"];
                     [photoAttributes setValue:UIImagePNGRepresentation(thumbnail) forKey:@"imageData"];
                     [photoAttributes setValue:[NSDate date] forKey:@"dateAdded"];
                     
                     [self.client insertNewPhotoWithValues:photoAttributes];
                     
                     [photoAttributes release];
                   }
                   failureBlock:nil];
    [assetsLibrary release];
  }
  
  // Stupid hack to force redraw the table.
  [self.tableView reloadData];
}
/**
 *  imagePickerControllerDidCancel
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Message Handlers

/**
 *  handleAddButtonTapped
 */
- (void)handleAddButtonTapped:(id)sender {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
    return;
  }

  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  
  // Displays saved pictures and movies, if both are available, from the Camera Roll album.
  imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
  imagePickerController.allowsEditing = NO;
  imagePickerController.delegate = self;
  
  [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
  [imagePickerController release];
}

#pragma mark - Instance Methods

/**
 *  configureCell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.imageView.image = [UIImage imageWithData:photo.imageData];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end