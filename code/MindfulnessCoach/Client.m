//
//  Client.m
//

#import "Client.h"
#import "Action.h"
#import "Activity.h"
#import "AppConstants.h"
#import "Exercise.h"
#import "Photo.h"
#import "Song.h"

@implementation Client

#pragma mark - Lifecycle

/**
 *  init
 */
- (id)init {
  self = [super init];
  if (self != nil) {
    _viewedLegalScreens = NO;
    _authorizedToRecordUsageData = NO;
    _contentVersion = nil;
  }
    [self deleteRandomRemindersIfPresent];
  return self;
}

/**
 *  initWithCoder
 */
- (id)initWithCoder:(NSCoder *)decoder {
  self = [super init];
  if (self != nil) {
    _viewedLegalScreens = [decoder decodeBoolForKey:@"client.viewedLegalScreens"];
    _authorizedToRecordUsageData = [decoder decodeBoolForKey:@"client.authorizedToRecordUsageData"];
    _contentVersion = [[decoder decodeObjectForKey:@"client.contentVersion"] copy];
  }
    [self deleteRandomRemindersIfPresent];
  return self;
}

/**
 *  encodeWithCoder
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
  [self saveManagedContext];
  
  [encoder encodeBool:self.hasViewedLegalScreens forKey:@"client.viewedLegalScreens"];
  [encoder encodeBool:self.isAuthorizedToRecordUsageData forKey:@"client.authorizedToRecordUsageData"];
  [encoder encodeObject:self.contentVersion forKey:@"client.contentVersion"];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_persistentStoreURL release];
  [_managedObjectModel release];
  [_managedObjectContext release];
  [_persistentStoreCoordinator release];
  [_contentVersion release];
  
  [super dealloc];
}

// fix to #4573, used to remove random reminders button on devices with an already installed app and cancel related local notifications
- (void) deleteRandomRemindersIfPresent {
    NSFetchedResultsController* controller = [self fetchedResultsControllerForActionsWithParent:[self rootActionForGroup:kActionGroupRemind]];
    for (int x=0; x< [[controller sections] count];x++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[controller sections] objectAtIndex:x];
        int c =[sectionInfo numberOfObjects];
        
        for(int y = 0;y<c;y++) {
            Action *action = [controller objectAtIndexPath:[NSIndexPath indexPathForItem:y inSection:x]];
            if([action.type isEqualToString:kActionTypeEditRandomReminders]) {
                [[self managedObjectContext] deleteObject:action];
                [[self managedObjectContext] save:nil];
            }
        }
    }
    NSArray* notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* cur in notifications) {
        if([[cur.userInfo objectForKey:kLocalNotificationTypeKey] isEqualToString:kLocalNotificationTypeRandomReminder]) {
            [[UIApplication sharedApplication] cancelLocalNotification:cur];
        }
    }
}

#pragma mark - Property Accessors

/**
 *  persistentStoreURL
 */
- (NSURL *)persistentStoreURL {
  if (_persistentStoreURL == nil) {
    NSString *applicationDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *persistentStorePath = [applicationDirectoryPath stringByAppendingPathComponent:@"MindfulnessCoach.sqlite"];
    _persistentStoreURL = [[NSURL alloc] initFileURLWithPath:persistentStorePath];
  }
  
  return _persistentStoreURL;
}

/**
 *  managedObjectContext
 */
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext == nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setUndoManager:nil];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  }
  
  return _managedObjectContext;
}

/**
 *  managedObjectModel
 */
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel == nil) {
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"MindfulnessCoach" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  }
  
  return _managedObjectModel;
}

/**
 *  persistentStoreCoordinator
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator == nil) {  
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.persistentStoreURL options:nil error:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }    
  }
  
  return _persistentStoreCoordinator;
}

#pragma mark - NSObject Methods

/**
 *  description
 */
- (NSString *)description {
  NSMutableArray *parts = [NSMutableArray arrayWithCapacity:3];
  [parts addObject:[NSString stringWithFormat:@"Content Version: %@", self.contentVersion]];
  [parts addObject:[NSString stringWithFormat:@"Legal Screens: %@", self.hasViewedLegalScreens ? @"YES" : @"NO"]];
  [parts addObject:[NSString stringWithFormat:@"Record Data: %@", self.isAuthorizedToRecordUsageData ? @"YES" : @"NO"]];
  
  return [parts componentsJoinedByString:@"\n"];
}

#pragma mark - Instance Methods

/**
 *  rootActionForGroup
 */
- (Action *)rootActionForGroup:(NSString *)group {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@ AND group == %@", kActionTypeRoot, group];
  NSArray *objects = [self fetchManagedObjectsWithEntityName:@"Action" predicate:predicate sortDescriptors:nil fetchLimit:1];
  
  return [objects lastObject];
}

/**
 *  allActivities
 */
- (NSArray *)allActivities {
  return [self allObjectsWithEntityName:@"Activity" sortKey:@"date" predicate:nil ascending:YES];
}

/**
 *  allExercises
 */
- (NSArray *)allExercises {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K < %@", @"rank", [NSNumber numberWithInteger:NSIntegerMax]];
  return [self allObjectsWithEntityName:@"Exercise" sortKey:@"rank" predicate:predicate ascending:YES];
}

/**
 *  fetchedResultsControllerForActionsWithParent
 */
- (NSFetchedResultsController *)fetchedResultsControllerForActionsWithParent:(Action *)parent {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", parent];
  return [self fetchedResultsControllerWithEntityName:@"Action"
                                              sortKey:@"rank"
                                        sortAscending:YES
                                            predicate:predicate
                                   sectionNameKeyPath:@"section"
                                            cacheName:nil];
}

/**
 *  fetchedResultsControllerForActivitiesSortedByDuration
 */
- (NSFetchedResultsController *)fetchedResultsControllerForActivitiesSortedByDuration:(BOOL)sortByDuration {
  NSString *sortKey = (sortByDuration ? @"duration" : @"date");
  
  return [self fetchedResultsControllerWithEntityName:@"Activity"
                                              sortKey:sortKey
                                        sortAscending:!sortByDuration
                                            predicate:nil
                                   sectionNameKeyPath:nil
                                            cacheName:nil];
}

/**
 *  fetchedResultsControllerForBlackouts
 */
- (NSFetchedResultsController *)fetchedResultsControllerForBlackouts {
  return [self fetchedResultsControllerWithEntityName:@"Blackout"
                                              sortKey:@"startDate"
                                        sortAscending:YES
                                            predicate:nil
                                   sectionNameKeyPath:nil
                                            cacheName:@"BlackoutsByStartDate"];
}

/**
 *  fetchedResultsControllerForExercises
 */
- (NSFetchedResultsController *)fetchedResultsControllerForExercises {
  return [self fetchedResultsControllerWithEntityName:@"Exercise"
                                              sortKey:@"rank"
                                        sortAscending:YES
                                            predicate:nil
                                   sectionNameKeyPath:nil
                                            cacheName:@"ExercisesByRank"];
}

/**
 *  fetchedResultsControllerForPhotos
 */
- (NSFetchedResultsController *)fetchedResultsControllerForPhotos {
  return [self fetchedResultsControllerWithEntityName:@"Photo"
                                              sortKey:@"dateAdded"
                                        sortAscending:YES
                                            predicate:nil
                                   sectionNameKeyPath:nil
                                            cacheName:@"PhotosByDateAdded"];
}

/**
 *  fetchedResultsControllerForSongs
 */
- (NSFetchedResultsController *)fetchedResultsControllerForSongs {
  return [self fetchedResultsControllerWithEntityName:@"Song"
                                              sortKey:@"dateAdded"
                                        sortAscending:YES
                                            predicate:nil
                                   sectionNameKeyPath:nil
                                            cacheName:@"SongsByDateAdded"];
}

/**
 *  fetchedResultsControllerWithEntityName:sortKey:cacheName
 */
- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)entityName
                                                               sortKey:(NSString *)sortKey
                                                         sortAscending:(BOOL)sortAscending
                                                             predicate:(NSPredicate *)predicate
                                                    sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                             cacheName:(NSString *)cacheName {
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
  NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entity];
  [fetchRequest setSortDescriptors:descriptors];
  [fetchRequest setPredicate:predicate];
  [fetchRequest setFetchBatchSize:20];
  
  [descriptors release];
  [sortDescriptor release];
  
  // Build a fetch results controller based on the above fetch request.
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                             managedObjectContext:self.managedObjectContext
                                                                                               sectionNameKeyPath:sectionNameKeyPath
                                                                                                        cacheName:cacheName];
  
  [fetchRequest release];
  
  NSError *error = nil;
  BOOL success = [fetchedResultsController performFetch:&error];
  if (success == NO) {
    // Not sure if we should return the 'dead' controller or just return 'nil'...
    // [fetchedResultsController setDelegate:nil];
    // [fetchedResultsController release];
    // fetchedResultsController = nil;
  }
  
  return [fetchedResultsController autorelease];
}

/**
 *  insertNewActionWithValues
 */
- (Action *)insertNewActionWithValues:(NSDictionary *)values {
  return (Action *)[self insertNewObjectForEntityForName:@"Action" withValues:values];
}

/**
 *  insertNewActivityWithValues
 */
- (Activity *)insertNewActivityWithValues:(NSDictionary *)values {
  return (Activity *)[self insertNewObjectForEntityForName:@"Activity" withValues:values];
}

/**
 *  insertNewBlackoutWithValues
 */
- (Blackout *)insertNewBlackoutWithValues:(NSDictionary *)values {
  return (Blackout *)[self insertNewObjectForEntityForName:@"Blackout" withValues:values];
}

/**
 *  insertNewExerciseWithValues
 */
- (Exercise *)insertNewExerciseWithValues:(NSDictionary *)values {
  return (Exercise *)[self insertNewObjectForEntityForName:@"Exercise" withValues:values];
}

/**
 *  insertNewPhotoWithValues
 */
- (Photo *)insertNewPhotoWithValues:(NSDictionary *)values {
  return (Photo *)[self insertNewObjectForEntityForName:@"Photo" withValues:values];
}

/**
 *  insertNewSongWithValues
 */
- (Song *)insertNewSongWithValues:(NSDictionary *)values {
  return (Song *)[self insertNewObjectForEntityForName:@"Song" withValues:values];
}

/**
 *  insertNewObjectForEntityForName:withValues
 */
- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName 
                                          withValues:(NSDictionary *)valuesDictionary {
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                          inManagedObjectContext:self.managedObjectContext];
  [valuesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [object setValue:[valuesDictionary valueForKey:key] forKey:key];
  }];

  return object;
} 

/**
 *  allObjectsWithEntityName:sortKey:predicate:ascending
 */
- (NSArray *)allObjectsWithEntityName:(NSString *)entityName sortKey:(NSString *)sortKey predicate:(NSPredicate *)predicate ascending:(BOOL)ascending {
  NSArray *descriptors = nil;
  
  if (sortKey != nil) {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [sortDescriptor release];
  }
  
  NSArray *objects = [self fetchManagedObjectsWithEntityName:entityName predicate:predicate sortDescriptors:descriptors fetchLimit:0];
  
  [descriptors release];
  
  return objects;
}

/**
 *  fetchManagedObjectsWithEntityName:predicate:sortDescriptors
 */
- (NSArray *)fetchManagedObjectsWithEntityName:(NSString *)entityName 
                                     predicate:(NSPredicate *)predicate 
                               sortDescriptors:(NSArray *)sortDescriptors 
                                    fetchLimit:(NSUInteger)fetchLimit {
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setPredicate:predicate];
  
  NSError *error = nil;
  NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  if (fetchedObjects == nil) {
    // If there was an error, then just return an empty array.
    // (I'll probably regret this decision at some point down the road...)
    return [NSArray array];
  }
  
  return fetchedObjects;
}

/**
 *  saveManagedContext
 */
- (void)saveManagedContext {
  NSError *error = nil;
  if ([self.managedObjectContext hasChanges]) {
    [self.managedObjectContext save:&error];
  }
}

/**
 *  deleteObject
 */
- (void)deleteObject:(NSManagedObject *)object {
  [self.managedObjectContext deleteObject:object];
}

/**
 *  deleteObjectsWithEntityName
 */
- (void)deleteObjectsWithEntityName:(NSString *)entityName {
  NSArray *objects = [self allObjectsWithEntityName:entityName sortKey:nil predicate:nil ascending:YES];
  NSLog(@"Deleting %d objects with entity name %@.", [objects count], entityName);
  
  for (NSManagedObject *managedObject in objects) {
    [self deleteObject:managedObject];
  }
}

/**
 *  deletePersistentStore
 */
- (void)deletePersistentStore {
  self.managedObjectContext = nil;
  self.managedObjectModel = nil;
  self.persistentStoreCoordinator = nil;
  
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filename = [[self.persistentStoreURL absoluteString] lastPathComponent];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    //NSLog(@"directoryContents ====== %@",[[NSFileManager defaultManager]
    //                                      contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    for (NSString *tString in directoryContents) {
        if ([tString hasPrefix:filename]) {
            NSString * file = [documentsDirectory stringByAppendingPathComponent:tString];
            [fileManager removeItemAtPath:file error:nil];
        }
    }
    
    //NSLog(@"directoryContents ====== %@",[[NSFileManager defaultManager]
    //                                      contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
  self.persistentStoreURL = nil;
}

@end
