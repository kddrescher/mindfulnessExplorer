//
//  ActivityEditViewController.h
//

#import "BaseLogEditViewController.h"

@class Activity;
@class Exercise;

enum {
  kActivityTableViewSectionExercise = 0,
  kActivityTableViewSectionDate,
  kActivityTableViewSectionTime,
  kActivityTableViewSectionDuration,
  kActivityTableViewSectionAudio,
  kActivityTableViewSectionComments,
  ACTIVITY_TABLE_VIEW_SECTION_COUNT
};

@interface ActivityEditViewController : BaseLogEditViewController

// Properties
@property(nonatomic, retain, readonly) Activity *activity;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client activity:(Activity *)activity;

// Instance Methods
- (void)setActivityExercise:(Exercise *)exercise;

@end
