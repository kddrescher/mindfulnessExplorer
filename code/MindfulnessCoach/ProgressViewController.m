//
//  ProgressViewController.m
//

#import "ProgressViewController.h"
#import "Activity.h"
#import "Client.h"
#import "GraphView.h"
#import "NSDate+VPDDate.h"
#import "UIView+VPDView.h"

#define BAR_POSITION @"POSITION"
#define BAR_HEIGHT @"HEIGHT"
#define COLOR @"COLOR"
#define CATEGORY @"CATEGORY"

#define AXIS_START 0
#define AXIS_END 50

@implementation ProgressViewController

#pragma mark - Lifecycle

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithWhite:0.975 alpha:1.0];
  
  UIImage *backgroundImage = [UIImage imageNamed:@"backgroundToolbar.png"];
  UIView *fakeToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
  fakeToolbar.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
  
  [self.view addSubview:fakeToolbar];
  
  NSArray *segmentedTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Last Week", nil),
                                                              NSLocalizedString(@"Last 2 Weeks", nil),
                                                              NSLocalizedString(@"Last Month", nil), nil];
  
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedTitles];
  segmentedControl.selectedSegmentIndex = 0;
  segmentedControl.tintColor = [UIColor colorWithWhite:0.55 alpha:1.0];
  
	[segmentedControl addTarget:self action:@selector(handleSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
  
  [fakeToolbar addSubview:segmentedControl];
  [segmentedControl centerVerticallyInView:fakeToolbar];
  [segmentedControl centerHorizontallyInView:fakeToolbar];
  
  CGRect graphFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - fakeToolbar.frame.size.height);
  GraphView *graphView = [[GraphView alloc] initWithFrame:graphFrame];
  graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  [self.view addSubview:graphView];
  [graphView positionBelowView:fakeToolbar margin:0.0];
  self.graphView = graphView;
  
  [graphView release];
  [fakeToolbar release];
  [segmentedControl release];
  [segmentedTitles release];

  [self handleSegmentedControlValueChanged:segmentedControl];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_activities release];
  
  [super dealloc];
}

#pragma mark - Event Handlers

/**
 *  handleSegmentedControlValueChanged
 */
- (void)handleSegmentedControlValueChanged:(id)sender {
  UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
  NSArray *allActivities = [self.client allActivities];
  NSDate *filterDate = [NSDate date];
  
  if (segmentedControl.selectedSegmentIndex == 0) {
    // Last Week
    filterDate = [filterDate dateByAddingDays:-7];
  } else if (segmentedControl.selectedSegmentIndex == 1) {
    // Last 2 Weeks
    filterDate = [filterDate dateByAddingDays:-14];
  } else if (segmentedControl.selectedSegmentIndex == 1) {
    // Last Month
    filterDate = [filterDate dateByAddingMonths:-1];
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@", filterDate];
  self.activities = [allActivities filteredArrayUsingPredicate:predicate];

  [self updateGraphView];
}

#pragma mark - Instance Methods

/**
 *  updateGraphView
 */
- (void)updateGraphView {
  self.graphView.yAxisTitle = NSLocalizedString(@"EXERCISE TIME IN MINUTES", nil);
  self.graphView.xAxisTitle = NSLocalizedString(@"DAY OF PRACTICE", nil);
  self.graphView.legendTitle = NSLocalizedString(@"Total number of minutes of\nMindfulness Activity per day.", nil);
    
  self.graphView.data = [self dataForGraph];
    
  [self.graphView setNeedsLayout];
}

/**
 *  arrayOfFakeData
 */
- (NSArray *)dataForGraph {
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:7];
  for (NSUInteger i = 0; i < 7; i++) {
    [array addObject:[NSMutableDictionary dictionaryWithCapacity:2]];
  }
  
  NSArray *barLabels = [NSArray arrayWithObjects:NSLocalizedString(@"MON", nil),
                                                 NSLocalizedString(@"TUE", nil),
                                                 NSLocalizedString(@"WED", nil),
                                                 NSLocalizedString(@"THU", nil),
                                                 NSLocalizedString(@"FRI", nil),
                                                 NSLocalizedString(@"SAT", nil),
                                                 NSLocalizedString(@"SUN", nil), nil];
  
  NSArray *accessibilityLabels = [NSArray arrayWithObjects:NSLocalizedString(@"Monday", nil),
                                                           NSLocalizedString(@"Tuesday", nil),
                                                           NSLocalizedString(@"Wednesday", nil),
                                                           NSLocalizedString(@"Thursday", nil),
                                                           NSLocalizedString(@"Friday", nil),
                                                           NSLocalizedString(@"Saturday", nil),
                                                           NSLocalizedString(@"Sunday", nil), nil];
  // Set up bar titles
  [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSMutableDictionary *dictionary = (NSMutableDictionary *)obj;
    [dictionary setValue:[NSNumber numberWithDouble:0.0] forKey:@"barValue"];
    [dictionary setValue:[barLabels objectAtIndex:idx] forKey:@"barLabel"];
    [dictionary setValue:[accessibilityLabels objectAtIndex:idx] forKey:@"accessibilityLabel"];
  }];
  
  
  [self.activities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    Activity *activity = (Activity *)obj;
    NSInteger weekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:activity.date] weekday];
    
    // From the Apple Docs:
    // Weekday units are the numbers 1 through n, where n is the number of days in the week. For example, 
    // in the Gregorian calendar, n is 7 and Sunday is represented by 1.
    
    // Our axis goes from Monday-Sunday, so move Sunday to the end of the line, move the
    // other weekdays back one, then normalize to zero based. (-2)
    NSInteger normalizedWeekday = (weekday == 1 ? 6 : weekday - 2);
    
    // Sanity Check...
    NSMutableDictionary *dictionary = [array objectAtIndex:normalizedWeekday];
    NSNumber *barValue = [dictionary valueForKey:@"barValue"];
    NSTimeInterval interval = [barValue doubleValue];
    interval += [activity.duration doubleValue];
    [dictionary setValue:[NSNumber numberWithDouble:interval] forKey:@"barValue"];
  }];
    
  return [array autorelease];
}

@end
