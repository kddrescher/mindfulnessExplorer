//
//  RoundedButton.m
//

#import "RoundedButton.h"
#import "Action.h"
#import "AppConstants.h"
#import "UIView+VPDView.h"

#define SMALL_BUTTON_WIDTH 150.0

@implementation RoundedButton

#pragma mark - Lifecycle

/**
 *  initWithFrame
 */
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    if (frame.size.width < SMALL_BUTTON_WIDTH) {
      [self setBackgroundImage:[UIImage imageNamed:@"roundButtonBackgroundSmall.png"] forState:UIControlStateNormal];
    } else {
      [self setBackgroundImage:[UIImage imageNamed:@"roundButtonBackgroundLarge.png"] forState:UIControlStateNormal];
    }
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleLabel.font = [AppConstants roundedButtonFont];
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentMode = UIViewContentModeScaleToFill;
  }
  
  return self;
}
/**
 *  dealloc
 */
- (void)dealloc {
  [_action release];
  [_userInfo release];
  
  [super dealloc];
}

#pragma mark - Instance Methods

/**
 *  layoutSubviews
 */
- (void)layoutSubviews {
  [super layoutSubviews];
  
  UILabel *label = [self titleLabel];
  label.numberOfLines = 0;
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  
  CGFloat edgePadding = 4.0;
  CGFloat shadowPadding = 4.0;
  CGSize contentSize = CGSizeMake(self.frame.size.width - (edgePadding * 2) - shadowPadding,
                                  self.frame.size.height - (edgePadding * 2) - shadowPadding);
  
  if (self.frame.size.width < SMALL_BUTTON_WIDTH) {
    label.textAlignment = NSTextAlignmentCenter;
    
    CGSize constraintSize = CGSizeMake(contentSize.width, CGFLOAT_MAX);
    CGRect boundingRect = [label.text boundingRectWithSize:constraintSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{NSFontAttributeName:label.font}
                                                   context:nil];
    [label resizeTo:boundingRect.size];
    [label centerHorizontallyInView:self];
    [label moveToBottomInParentWithMargin:edgePadding + shadowPadding + 5.0];
    
    CGFloat imageViewHeight = label.frame.origin.y - kUIViewVerticalMargin - edgePadding;
    CGSize imageViewSize = CGSizeMake(self.frame.size.width - (edgePadding * 2) - shadowPadding, imageViewHeight);
    
    [self.imageView resizeTo:imageViewSize];
    [self.imageView centerHorizontallyInView:self];
    [self.imageView moveToTopInParentWithMargin:kUIViewVerticalMargin];
  } else {
    // The 110.0 is a magic number to give the icon on the left some breathing room.
    CGSize labelSize = CGSizeMake(self.frame.size.width - 110.0 - (edgePadding * 2) - shadowPadding,
                                  self.frame.size.height - (edgePadding * 2) - shadowPadding);
    
    label.textAlignment = NSTextAlignmentLeft;
    [label resizeTo:labelSize];
    [label moveToRightInParentWithMargin:edgePadding + shadowPadding + 10.0];
    [label moveToTopInParentWithMargin:edgePadding];
    
    [self.imageView resizeTo:CGSizeMake(80.0, self.frame.size.height - (edgePadding * 2) - shadowPadding)];
    [self.imageView centerVerticallyInView:self];
    [self.imageView moveToLeftInParentWithMargin:edgePadding];
  }
}

@end
