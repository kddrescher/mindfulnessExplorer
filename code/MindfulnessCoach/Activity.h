//
//  Activity.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise;

@interface Activity : NSManagedObject

// Attributes
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic, retain) NSNumber *audio;
@property(nonatomic, retain) NSString *comments;

// Relationships
@property(nonatomic, retain) Exercise *exercise;

@end
