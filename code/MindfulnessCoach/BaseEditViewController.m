//
//  BaseEditViewController.m
//

#import "BaseEditViewController.h"
#import "Client.h"

@implementation BaseEditViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client:managedObject
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client managedObject:(NSManagedObject *)managedObject {
  self = [super initWithStyle:style client:client];
  if (self != nil) {
    _popViewControllerInsteadOfDismissing = NO;
    
    _managedObject = [managedObject retain];
    _scratchManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [_scratchManagedObjectContext setUndoManager:nil];
    [_scratchManagedObjectContext setPersistentStoreCoordinator:self.client.persistentStoreCoordinator];
    
    // Add a 'Cancel' button in the top left.
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self 
                                                                                      action:@selector(handleCancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    // Add a 'Save' button in the top right.
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(handleDoneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [saveButtonItem release];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_doneBlock release];
  [_cancelledBlock release];
  [_managedObject release];
  [_scratchObject release];
  [_scratchManagedObjectContext release];
  [_scratchObjectEntityName release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  scratchObject
 */
- (NSManagedObject *)scratchObject {
  if (_scratchObject == nil) {
    if (self.managedObject == nil) {
      _scratchObject = [[NSEntityDescription insertNewObjectForEntityForName:self.scratchObjectEntityName
                                                      inManagedObjectContext:self.scratchManagedObjectContext] retain];
      [self populateDefaultValuesWithNewManagedObject:_scratchObject];
    } else {
      _scratchObject = [[self.scratchManagedObjectContext objectWithID:self.managedObject.objectID] retain];
    }
  }
  
  return _scratchObject;
}

#pragma mark - Event Handlers

/**
 *  handleCancelButtonTapped
 */
- (void)handleCancelButtonTapped:(id)sender {
  if (self.cancelledBlock != nil) {
    self.cancelledBlock();
  }
  
  if (self.popViewControllerInsteadOfDismissing) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

/**
 *  handleDoneButtonTapped
 */
- (void)handleDoneButtonTapped:(id)sender {
  NSNotificationCenter *nofiticationCenter = [NSNotificationCenter defaultCenter];
  [nofiticationCenter addObserver:self 
                         selector:@selector(handleScratchManagedObjectContextDidSave:) 
                             name:NSManagedObjectContextDidSaveNotification 
                           object:self.scratchManagedObjectContext];
  
  NSError *error = nil;
  if ([self.scratchManagedObjectContext save:&error] == NO) {
    NSLog(@"Error saving scratch context in edit view controller. Error: %@, %@", error, [error userInfo]);
    exit(-1);  // Fail
  }
  
  [nofiticationCenter removeObserver:self 
                                name:NSManagedObjectContextDidSaveNotification 
                              object:self.scratchManagedObjectContext];
  
  if (self.doneBlock != nil) {
    self.doneBlock();
  }
  
  if (self.popViewControllerInsteadOfDismissing) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

/**
 *  handleScratchManagedObjectContextDidSave
 */
- (void)handleScratchManagedObjectContextDidSave:(NSNotification*)saveNotification {
	[self.client.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

#pragma mark - Instance Methods

/**
 *  populateDefaultValuesWithNewManagedObject
 */
- (void)populateDefaultValuesWithNewManagedObject:(NSManagedObject *)managedObject {
  // Intentionally left blank.
}

@end
