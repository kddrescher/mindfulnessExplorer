//
//  GraphView.h
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView {
  UIEdgeInsets graphInset_;
  NSString *xAxisTitle_;
  NSString *yAxisTitle_;
  NSUInteger yAxisIntervalCount_;

  NSString *legendTitle_;

  UIColor *barColor_;
  CGFloat barWidth_;

  NSArray *data_;
  NSMutableArray *_accessibilityElements ;
}

// Properties
@property(nonatomic, assign) UIEdgeInsets graphInset;
@property(nonatomic, copy) NSString *xAxisTitle;
@property(nonatomic, copy) NSString *yAxisTitle;
@property(nonatomic, assign) NSUInteger yAxisIntervalCount;
@property(nonatomic, copy) NSString *legendTitle;

@property(nonatomic, retain) UIColor *barColor;
@property(nonatomic, assign) CGFloat barWidth;

@property(nonatomic, retain) NSArray *data;
@property(nonatomic, retain) NSMutableArray *accessibilityElements;

// Instance Methods
- (void)layoutGraph;
- (UILabel *)labelForAxisWithTitle:(NSString *)title;
- (UILabel *)labelForIntervalWithTitle:(NSString *)title;

@end
