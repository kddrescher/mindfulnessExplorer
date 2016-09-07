//
//  Action.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Action : NSManagedObject

// Attributes
@property(nonatomic, retain) NSString *accessoryType;
@property(nonatomic, retain) NSNumber *completed;
@property(nonatomic, retain) NSString *details;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *group;
@property(nonatomic, retain) NSString *helpFilename;
@property(nonatomic, retain) NSString *icon;
@property(nonatomic, retain) NSString *instructions;
@property(nonatomic, retain) NSString *navigationTitle;
@property(nonatomic, retain) NSNumber *rank;
@property(nonatomic, retain) NSString *section;
@property(nonatomic, retain) NSString *style;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *uid;
@property(nonatomic, retain) NSString *userInfo;

// Relationships
@property(nonatomic, retain) NSSet *children;
@property(nonatomic, retain) Action *parent;

// Instance Methods
- (NSArray *)childrenSortedByRank;

@end

@interface Action (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Action *)value;
- (void)removeChildrenObject:(Action *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
