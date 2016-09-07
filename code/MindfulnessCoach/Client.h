//
//  Client.h
//

#import <Foundation/Foundation.h>

@class Action;
@class Activity;
@class Blackout;
@class Exercise;
@class Photo;
@class Song;

@interface Client : NSObject

// Properties
@property(nonatomic, retain) NSURL *persistentStoreURL;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic, assign, getter = hasViewedLegalScreens) BOOL viewedLegalScreens;
@property(nonatomic, assign, getter = isAuthorizedToRecordUsageData) BOOL authorizedToRecordUsageData;
@property(nonatomic, copy) NSString *contentVersion;

// Instance Methods
- (Action *)rootActionForGroup:(NSString *)group;

- (NSArray *)allActivities;
- (NSArray *)allExercises;

- (NSFetchedResultsController *)fetchedResultsControllerForActionsWithParent:(Action *)parent;
- (NSFetchedResultsController *)fetchedResultsControllerForActivitiesSortedByDuration:(BOOL)sortByDuration;
- (NSFetchedResultsController *)fetchedResultsControllerForBlackouts;
- (NSFetchedResultsController *)fetchedResultsControllerForExercises;
- (NSFetchedResultsController *)fetchedResultsControllerForPhotos;
- (NSFetchedResultsController *)fetchedResultsControllerForSongs;


- (Action *)insertNewActionWithValues:(NSDictionary *)values;
- (Activity *)insertNewActivityWithValues:(NSDictionary *)values;
- (Blackout *)insertNewBlackoutWithValues:(NSDictionary *)values;
- (Exercise *)insertNewExerciseWithValues:(NSDictionary *)values;
- (Photo *)insertNewPhotoWithValues:(NSDictionary *)values;
- (Song *)insertNewSongWithValues:(NSDictionary *)values;

- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName 
                                          withValues:(NSDictionary *)valuesDictionary;
- (NSArray *)allObjectsWithEntityName:(NSString *)entityName
                              sortKey:(NSString *)sortKey
                            predicate:(NSPredicate *)predicate
                            ascending:(BOOL)ascending;
- (NSArray *)fetchManagedObjectsWithEntityName:(NSString *)entityName 
                                     predicate:(NSPredicate *)predicate 
                               sortDescriptors:(NSArray *)sortDescriptors 
                                    fetchLimit:(NSUInteger)fetchLimit;

- (void)saveManagedContext;
- (void)deleteObject:(NSManagedObject *)object;
- (void)deleteObjectsWithEntityName:(NSString *)entityName;
- (void)deletePersistentStore;

@end
