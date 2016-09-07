//
//  GraphView.m
//

#import "GraphView.h"
#import "AppConstants.h"
#import "UIView+VPDView.h"

@implementation GraphView



#pragma mark - Lifecycle

/**
 *  initWithFrame
 */
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    _graphInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 10.0);
    _yAxisIntervalCount = 3;
    _barColor = [[UIColor alloc] initWithRed:91.0/255.0 green:142.0/255.0 blue:173.0/255.0 alpha:1.0];
    _barWidth = 16.0;
    _accessibilityElements = [[NSMutableArray alloc] initWithCapacity:16];
  }
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_xAxisTitle release];
  [_yAxisTitle release];
  [_legendTitle release];
  [_barColor release];
  [_data release];
  [_accessibilityElements release];
  
  [super dealloc];
}

#pragma mark - UIView Methods

/**
 *  layoutSubviews
 */
- (void)layoutSubviews {
  [self layoutGraph];
}

#pragma mark - UIAccessibilityContainer

/**
 *  accessibilityElementAtIndex
 */
- (id)accessibilityElementAtIndex:(NSInteger)index {
  return [self.accessibilityElements objectAtIndex:index];
}

/**
 *  accessibilityElementCount
 */
- (NSInteger)accessibilityElementCount {
  return [self.accessibilityElements count];
}

/**
 *  indexOfAccessibilityElement
 */
- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [self.accessibilityElements indexOfObject:element];
}

#pragma mark - Instance Methods

/**
 *  layoutGraph
 */
- (void)layoutGraph {
  for (UIView *subview in self.subviews) {
    [subview removeFromSuperview];
  }

  [self.accessibilityElements removeAllObjects];
  
  CGFloat plottingFrameLeftMargin = 50.0;
  CGFloat plottingFrameBottomMargin = 90.0;
  
  CGFloat kAxisThickness = 1.0;
  
  CGRect plottingFrame = self.bounds;
  plottingFrame.origin = CGPointMake(self.graphInset.left + plottingFrameLeftMargin, self.graphInset.top);
  plottingFrame.size = CGSizeMake(plottingFrame.size.width - (self.graphInset.left + self.graphInset.right) - plottingFrameLeftMargin,
                                  plottingFrame.size.height - (self.graphInset.top + self.graphInset.bottom) - plottingFrameBottomMargin);
  
  // Y Axis
  UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(plottingFrame.origin.x - kAxisThickness, plottingFrame.origin.y, kAxisThickness, plottingFrame.size.height)];
  yAxis.backgroundColor = self.barColor;
  [self addSubview:yAxis];
  
  // Y Axis Title
  UILabel *yAxisLabel = [self labelForAxisWithTitle:self.yAxisTitle];
  yAxisLabel.accessibilityHint = NSLocalizedString(@"Y Axis Title", nil);
  yAxisLabel.transform = CGAffineTransformMakeRotation(- 90.0f * M_PI / 180.0f);
  
  CGFloat yAxisLabelXPos = self.graphInset.left + yAxisLabel.frame.size.width / 2;
  CGFloat yAxisLabelYPos = plottingFrame.origin.y + (plottingFrame.size.height / 2);
  yAxisLabel.center = CGPointMake(yAxisLabelXPos, yAxisLabelYPos);

  [self addSubview:yAxisLabel];
  [self.accessibilityElements addObject:yAxisLabel];

  // Determine max-y value for y axis labels.
  CGFloat maxValue = 0.0;
  for (NSDictionary *dictionary in self.data) {
    NSNumber *value = [dictionary valueForKey:@"barValue"];
    maxValue = MAX(maxValue, [value floatValue]);
  }
  
  // Y Axis Labels
  CGFloat yIntervalDelta = maxValue / (self.yAxisIntervalCount - 1);
  for (NSUInteger i = 0; i < self.yAxisIntervalCount; i++) {
    CGFloat yValue = maxValue - (i * yIntervalDelta);
    UILabel *intervalLabel = [self labelForIntervalWithTitle:[NSString stringWithFormat:@"%.0f", yValue / 60]];
    intervalLabel.center = CGPointMake(0.0, plottingFrame.origin.y + ((plottingFrame.size.height / (self.yAxisIntervalCount - 1)) * i));
    [self addSubview:intervalLabel];
    [intervalLabel positionToTheLeftOfView:yAxis margin:2.0];
  }
  
  // X Axis
  UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(plottingFrame.origin.x, plottingFrame.origin.y + plottingFrame.size.height, plottingFrame.size.width, kAxisThickness)];
  xAxis.backgroundColor = self.barColor;
  
  [self addSubview:xAxis];

  // X Axis Labels
  CGFloat barGap = (plottingFrame.size.width - ([self.data count] * self.barWidth)) / [self.data count];
  CGFloat xLabelOffset = plottingFrame.origin.x + (barGap / 2) + (self.barWidth / 2);
  for (NSDictionary *dictionary in self.data) {
    UILabel *intervalLabel = [self labelForIntervalWithTitle:[dictionary valueForKey:@"barLabel"]];
    intervalLabel.accessibilityLabel = [dictionary valueForKey:@"accessibilityLabel"];
                                        
    [self addSubview:intervalLabel];
    [intervalLabel positionBelowView:xAxis margin:2.0];
    intervalLabel.center = CGPointMake(xLabelOffset, intervalLabel.center.y);
    
    xLabelOffset += barGap + self.barWidth;
    
    NSNumber *barValue = [dictionary valueForKey:@"barValue"];
    CGFloat normalizedRatio = (maxValue == 0 ? 0 : [barValue floatValue] / maxValue);
    CGFloat normalizedHeight = plottingFrame.size.height * normalizedRatio;

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.barWidth, normalizedHeight)];
    barView.accessibilityLabel = [dictionary valueForKey:@"accessibilityLabel"];
    barView.accessibilityValue = [NSString stringWithFormat:@"%d %@", [barValue integerValue] / 60, NSLocalizedString(@"minutes", nil)];
    barView.backgroundColor = self.barColor;
    barView.isAccessibilityElement = YES;
    
    [self addSubview:barView];
    [barView positionAboveView:xAxis margin:0.0];
    barView.center = CGPointMake(intervalLabel.center.x, barView.center.y);
    
    if ([barValue floatValue] == 0.0) {
      intervalLabel.accessibilityValue = NSLocalizedString(@"0 minutes", nil);
      [self.accessibilityElements addObject:intervalLabel];
    } else {
      [self.accessibilityElements addObject:barView];
    }
    
    [barView release];
  }
  
  // Legend Swatch
  CGFloat swatchWidth = 10.0;
  UIView *legendSwatch = [[UIView alloc] initWithFrame:CGRectMake(plottingFrame.origin.x, 0.0, swatchWidth, swatchWidth)];
  legendSwatch.backgroundColor = self.barColor;
  
  [self addSubview:legendSwatch];
  
  // Legend Title
  UILabel *legendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  legendLabel.accessibilityHint = NSLocalizedString(@"Legend", nil);
  legendLabel.backgroundColor = [UIColor clearColor];
  legendLabel.font = [UIFont boldSystemFontOfSize:12.0];
  legendLabel.numberOfLines = 0;
  legendLabel.text = self.legendTitle;
  legendLabel.textColor = [UIColor darkGrayColor];
  
  [legendLabel sizeToFit];
  
  [self addSubview:legendLabel];
  [self.accessibilityElements addObject:legendLabel];
  
  [legendLabel positionToTheRightOfView:legendSwatch margin:kUIViewHorizontalMargin / 2];
  [legendLabel moveToBottomInParentWithMargin:self.graphInset.bottom];
  [legendSwatch alignTopWithView:legendLabel];
  
  plottingFrame.size.height -= legendLabel.frame.size.height;
  
  // X Axis Title
  UILabel *xAxisLabel = [self labelForAxisWithTitle:self.xAxisTitle];
  xAxisLabel.accessibilityHint = NSLocalizedString(@"X Axis Title", nil);
  [self addSubview:xAxisLabel];
  [xAxisLabel positionAboveView:legendLabel margin:kUIViewVerticalMargin];
  xAxisLabel.center = CGPointMake(plottingFrame.origin.x + (plottingFrame.size.width / 2), xAxisLabel.frame.origin.y);
  
  // Inject this so that it gets read after the yAxisLabel
  [self.accessibilityElements insertObject:xAxisLabel atIndex:1];  
  
  [legendSwatch release];
  [legendLabel release];

  [xAxis release];
  [yAxis release];
}

/**
 *  labelForAxisWithTitle
 */
- (UILabel *)labelForAxisWithTitle:(NSString *)title {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont boldSystemFontOfSize:13.0];
  label.text = title;
  label.textColor = [UIColor darkGrayColor];
    
  [label sizeToFit];
  
  return [label autorelease];
}

/**
 *  labelForIntervalWithTitle
 */
- (UILabel *)labelForIntervalWithTitle:(NSString *)title {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont boldSystemFontOfSize:11.0];
  label.text = title;
  label.textAlignment = NSTextAlignmentRight;
  label.textColor = self.barColor;
  
  [label sizeToFit];
  
  return [label autorelease];
}

@end
