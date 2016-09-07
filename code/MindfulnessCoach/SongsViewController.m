//
//  SongsViewController.m
//

#import "SongsViewController.h"
#import "Client.h"
#import "Song.h"
#import "UIFactory.h"

@implementation SongsViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:UITableViewStylePlain client:client];
  if (self != nil) {
    self.navigationItem.title = NSLocalizedString(@"Select Songs", nil);

    UIBarButtonItem *addSongButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(handleAddButtonTapped:)];
    self.navigationItem.rightBarButtonItem = addSongButtonItem;
    [addSongButtonItem release];
  }
  
  return self;
}

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForSongs]];
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
 *  tableView:commitEditingStyle:forRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.client deleteObject:objectToDelete];
  }
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithSubtitleStyleFromTableView:tableView];
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods


/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Intentionally left blank.
}

#pragma mark - MPMediaPickerControllerDelegate Methods

/**
 *  mediaPicker:didPickMediaItems
 */
- (void) mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection {
  [self dismissViewControllerAnimated:YES completion:nil];
  
  [collection.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    // Allow a maximum of 20 songs.
    if ([[self.fetchedResultsController fetchedObjects] count] >= 20) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Maximum Songs Reached.", nil)
                                                          message:NSLocalizedString(@"You have reached the maximum song count of 20. "
                                                                                      "Please remove existing songs from your list before "
                                                                                      "attempting to add new ones.", nil)
                                                         delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                otherButtonTitles:nil];
      
      [alertView show];
      [alertView release];
      *stop = YES;
    } else {
      MPMediaItem *mediaItem = (MPMediaItem *)obj;
      
      NSMutableDictionary *songAttributes = [[NSMutableDictionary alloc] initWithCapacity:4];
      [songAttributes setValue:[mediaItem valueForKey:MPMediaItemPropertyTitle] forKey:@"title"];
      [songAttributes setValue:[mediaItem valueForKey:MPMediaItemPropertyAlbumTitle] forKey:@"album"];
      [songAttributes setValue:[mediaItem valueForKey:MPMediaItemPropertyArtist] forKey:@"artist"];
      [songAttributes setValue:[NSDate date] forKey:@"dateAdded"];
      
      Song *song = [self.client insertNewSongWithValues:songAttributes];
      
      // Need to manually set the persistent ID
      NSNumber *persistentIDNumber = [mediaItem valueForKey:MPMediaItemPropertyPersistentID];
      [song setPersistentID:[persistentIDNumber unsignedLongLongValue]];
      
      [songAttributes release];
    }
  }];
  
  // Stupid hack to force redraw the table.
  [self.tableView reloadData];
}

/**
 *  mediaPickerDidCancel
 */
- (void) mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Message Handlers

/**
 *  handleAddButtonTapped
 */
- (void)handleAddButtonTapped:(id)sender {
  MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
  [picker setDelegate: self];
  [picker setAllowsPickingMultipleItems: YES];
  picker.prompt = NSLocalizedString (@"Select Soothing Songs", nil);
  
  [self presentViewController:picker animated:YES completion:nil];
  [picker release];
}

#pragma mark - Instance Methods

/**
 *  configureCell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.textLabel.text = song.title;
}

@end