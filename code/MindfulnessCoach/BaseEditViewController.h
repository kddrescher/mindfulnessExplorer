//
//  BaseEditViewController.h
//

#import "BaseTableViewController.h"

typedef void (^EditViewDoneBlock)(void);
typedef void (^EditViewCancelledBlock)(void);

@interface BaseEditViewController : BaseTableViewController

// Properties
@property(nonatomic, assign) BOOL popViewControllerInsteadOfDismissing;
@property(nonatomic, copy) EditViewDoneBlock doneBlock;
@property(nonatomic, copy) EditViewCancelledBlock cancelledBlock;
@property(nonatomic, retain) NSManagedObject *managedObject;
@property(nonatomic, retain) NSManagedObject *scratchObject;
@property(nonatomic, retain) NSManagedObjectContext *scratchManagedObjectContext;
@property(nonatomic, copy) NSString *scratchObjectEntityName;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client managedObject:(NSManagedObject *)managedObject;

// Event Handlers
- (void)handleCancelButtonTapped:(id)sender;
- (void)handleDoneButtonTapped:(id)sender;
- (void)handleScratchManagedObjectContextDidSave:(NSNotification*)saveNotification;

// Instance Methods
- (void)populateDefaultValuesWithNewManagedObject:(NSManagedObject *)managedObject;

@end
