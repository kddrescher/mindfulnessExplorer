//
//  Song.m
//

#import "Song.h"

@implementation Song

#pragma mark - Attributes

@dynamic album;
@dynamic artist;
@dynamic dateAdded;
@dynamic persistentIDData;
@dynamic title;

#pragma mark - Properties

// CoreData doesn't natively support uint64_t, which is required to store persistent IDs from the MediaPicker.
// http://stackoverflow.com/questions/9546882/store-unsigned-long-long-using-core-data

/**
 *  setPersistentID
 */
- (void)setPersistentID:(uint64_t)persistentIDUInt64 {
  self.persistentIDData = [NSData dataWithBytes:&persistentIDUInt64 length:sizeof(persistentIDUInt64)];
}

/**
 *  persistentID
 */
- (uint64_t)persistentID {
  uint64_t persistentIDUInt64;
  [self.persistentIDData getBytes:&persistentIDUInt64 length:sizeof(persistentIDUInt64)];
  return persistentIDUInt64;
}

#pragma mark - Instance Methods

/**
 *  mediaItem
 */
- (MPMediaItem *)mediaItem {
  NSNumber *persistentIDNumber = [NSNumber numberWithUnsignedLongLong:self.persistentID];
  MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
  [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:persistentIDNumber forProperty:MPMediaItemPropertyPersistentID]];
  
  MPMediaItem *item = nil;
  NSArray *mediaItems = [songQuery items];
  if ([mediaItems count] > 0) {
    item = [mediaItems lastObject];
  }
  
  return item;
}

@end
