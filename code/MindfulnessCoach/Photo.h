//
//  Photo.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Photo : NSManagedObject

// Attributes
@property(nonatomic, retain) NSDate *dateAdded;
@property(nonatomic, retain) NSData *imageData;
@property(nonatomic, retain) NSString *mediaPath;
@property(nonatomic, retain) NSString *referencePath;
@property(nonatomic, retain) NSString *title;

@end
