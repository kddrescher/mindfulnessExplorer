//
//  ProgressViewController.h
//

#import "BaseViewController.h"

@class GraphView;

enum {
  kProgressSegmentedControlIndexLastWeek = 0,
  kProgressSegmentedControlIndexLastTwoWeeks,
  kProgressSegmentedControlIndexLastMonth
};

@interface ProgressViewController : BaseViewController

// Properties
@property(nonatomic, retain) GraphView *graphView;
@property(nonatomic, retain) NSArray *activities;

// Event Handlers
- (void)handleSegmentedControlValueChanged:(id)sender;

// Instance Methods
- (void)updateGraphView;

@end
