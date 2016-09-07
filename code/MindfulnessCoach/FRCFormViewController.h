//
//  FRCFormViewController.h
//

#import "FormViewController.h"

@interface FRCFormViewController : FormViewController<NSFetchedResultsControllerDelegate>

// Properties
@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
