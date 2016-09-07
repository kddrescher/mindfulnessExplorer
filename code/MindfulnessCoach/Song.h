//
//  Song.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Song : NSManagedObject

// Attributes
@property(nonatomic, retain) NSString *album;
@property(nonatomic, retain) NSString *artist;
@property(nonatomic, retain) NSDate *dateAdded;
@property(nonatomic, retain) NSData *persistentIDData;
@property(nonatomic, retain) NSString *title;

// Properties
- (void)setPersistentID:(uint64_t)persistentIDUInt64;
- (uint64_t)persistentID;

// Instance Methods
- (MPMediaItem *)mediaItem;

@end
