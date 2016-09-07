//
//  Exercise.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Exercise : NSManagedObject

// Attributes
@property(nonatomic, retain) NSNumber *favorite;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSNumber *rank;
@property(nonatomic, retain) NSString *title;

@end
