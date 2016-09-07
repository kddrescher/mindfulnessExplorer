//
//  Blackout.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Blackout : NSManagedObject

// Attributes
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSDate *endDate;

@end
