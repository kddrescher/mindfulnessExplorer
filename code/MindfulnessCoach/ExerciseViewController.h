//
//  ExerciseViewController.h
//

#import "WebViewController.h"

@class Client;
@class Exercise;

@interface ExerciseViewController : WebViewController

// Properties
@property(nonatomic, retain) Exercise *exercise;

// Initializers
- (id)initWithClient:(Client *)client exercise:(Exercise *)exercise;

@end
