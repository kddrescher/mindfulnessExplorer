//
//  ExerciseEventEditViewController.h
//

#import <EventKitUI/EventKitUI.h>

#import "BaseEditViewController.h"
#import "AppConstants.h"

@class Exercise;

enum {
  kExerciseEventTableViewSectionExercise = 0,
  kExerciseEventTableViewSectionFrequency,
  kExerciseEventTableViewSectionChime
};

@interface ExerciseEventEditViewController : BaseEditViewController<EKEventEditViewDelegate>

// Properties
@property(nonatomic, retain) Exercise *exercise;
@property(nonatomic, assign) BOOL chime;
@property(nonatomic, assign) NotificationFrequency notificationFrequency;

// Event Handlers
- (void)handleChimeValueChanged:(id)sender;
- (void)handleAddToCalendarButtonTapped:(id)sender;

@end
