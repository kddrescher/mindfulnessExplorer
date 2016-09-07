//
//  UIView+VPDView.m
//

#import "UIView+VPDView.h"

@implementation UIView (VPDView)

/**
 *  positionAboveView:margin
 */
- (void)positionAboveView:(UIView *)reference margin:(CGFloat)margin {
  CGRect frame = self.frame;
  frame.origin.y = reference.frame.origin.y - frame.size.height - margin;
  self.frame = frame;
}

/**
 *  positionBelowView:margin
 */
- (void)positionBelowView:(UIView *)reference margin:(CGFloat)margin {
  CGRect frame = self.frame;
  frame.origin.y = reference.frame.origin.y + reference.frame.size.height + margin;
  self.frame = frame;
}

/**
 *  positionToTheRightOfView:margin
 */
- (void)positionToTheRightOfView:(UIView *)reference margin:(CGFloat)margin {
  CGRect frame = self.frame;
  frame.origin.x = reference.frame.origin.x + reference.frame.size.width + margin;
  self.frame = frame;
}

/**
 *  positionToTheLeftOfView:margin
 */
- (void)positionToTheLeftOfView:(UIView *)reference margin:(CGFloat)margin {
  CGRect frame = self.frame;
  frame.origin.x = reference.frame.origin.x - frame.size.width - margin;
  self.frame = frame;
}

/**
 *  positionAtTheBottomofView:margin
 */
- (void)positionAtTheBottomofView:(UIView *)reference margin:(CGFloat)margin {
  CGRect frame = self.frame;
  frame.origin.y = reference.frame.size.height - frame.size.height - margin;
  self.frame = frame;
}

/**
 *  alignLeftWithView
 */
- (void)alignLeftWithView:(UIView *)reference {
  CGRect frame = self.frame;
  frame.origin.x = reference.frame.origin.x;
  self.frame = frame;
}

/**
 *  alignRightWithView
 */
- (void)alignRightWithView:(UIView *)reference {
  CGRect frame = self.frame;
  CGFloat referenceRight = reference.frame.origin.x + reference.frame.size.width;
  CGFloat ourRight = frame.origin.x + frame.size.width;
  
  frame.origin.x += (referenceRight - ourRight);
  self.frame = frame;
}

/**
 *  alignTopWithView
 */
- (void)alignTopWithView:(UIView *)reference {
  CGRect frame = self.frame;
  frame.origin.y = reference.frame.origin.y;
  self.frame = frame;
}

/**
 *  alignBottomWithView
 */
- (void)alignBottomWithView:(UIView *)reference {
  CGRect frame = self.frame;
  CGFloat referenceBottom = reference.frame.origin.y + reference.frame.size.height;
  CGFloat ourBottom = frame.origin.y + frame.size.height;
  
  frame.origin.y += (referenceBottom - ourBottom);
  self.frame = frame;
}

/**
 *  alignVerticalWithView
 */
- (void)alignVerticalWithView:(UIView *)reference {
  CGRect frame = self.frame;
  frame.origin.y = ceil(reference.frame.origin.y + ((reference.frame.size.height - frame.size.height) / 2));
  
  self.frame = frame;
}


/**
 *  alignHorizontalWithView
 */
- (void)alignHorizontalWithView:(UIView *)reference {
  CGRect frame = self.frame;
  frame.origin.x = ceil(reference.frame.origin.x + ((reference.frame.size.width - frame.size.width) / 2));
  
  self.frame = frame;
}

/**
 *  moveToPoint
 */
- (void)moveToPoint:(CGPoint)point {
  CGRect frame = self.frame;
  frame.origin = point;
  
  self.frame = frame;
}

/**
 *  moveToBottomInParent
 */
- (void)moveToBottomInParent {
  [self moveToBottomInParentWithMargin:0.0];
}

/**
 *  moveToBottomInParentWithMargin
 */
- (void)moveToBottomInParentWithMargin:(CGFloat)margin {
  if (self.superview != nil) {
    [self moveToPoint:CGPointMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height - margin)];
  }
}

/**
 *  moveToTopInParent
 */
- (void)moveToTopInParent {
  [self moveToTopInParentWithMargin:0.0];
}

/**
 *  moveToTopInParentWithMargin
 */
- (void)moveToTopInParentWithMargin:(CGFloat)margin {
  [self moveToPoint:CGPointMake(self.frame.origin.x, margin)];
}

/**
 *  moveToRightInParent
 */
- (void)moveToRightInParent {
  [self moveToRightInParentWithMargin:0.0];
}

/**
 *  moveToRightInParentWithMargin
 */
- (void)moveToRightInParentWithMargin:(CGFloat)margin {
  if (self.superview != nil) {
    [self moveToPoint:CGPointMake(self.superview.frame.size.width - self.frame.size.width - margin, self.frame.origin.y)];
  }
}

/**
 *  moveToLeftInParent
 */
- (void)moveToLeftInParent {
  [self moveToLeftInParentWithMargin:0.0];
}

/**
 *  moveToLeftInParentWithMargin
 */
- (void)moveToLeftInParentWithMargin:(CGFloat)margin {
  if (self.superview != nil) {
    [self moveToPoint:CGPointMake(margin, self.frame.origin.y)];
  }
}

/**
 *  centerHorizontallyInView
 */
- (void)centerHorizontallyInView:(UIView *)reference {
  [self moveToPoint:CGPointMake(ceil((reference.frame.size.width - self.frame.size.width) / 2), self.frame.origin.y)];
}


/**
 *  centerVerticallyInView
 */
- (void)centerVerticallyInView:(UIView *)reference {
  [self moveToPoint:CGPointMake(self.frame.origin.x, ceil((reference.frame.size.height - self.frame.size.height) / 2))];
}

/**
 *  offsetYOriginBy
 */
- (void)offsetYOriginBy:(CGFloat)delta {
  CGRect frame = self.frame;
  frame.origin.y += delta;
  self.frame = frame;
}

/**
 *  resizeHeightBy
 */
- (void)resizeHeightBy:(CGFloat)delta {
  CGRect frame = self.frame;
  frame.size.height += delta;
  self.frame = frame;
}

/**
 *  resizeTo
 */
- (void)resizeTo:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
}

/**
 *  resizeHeightToContainSubviewsWithMargin
 */
- (void)resizeHeightToContainSubviewsWithMargin:(CGFloat)margin {
  CGRect frame = self.frame;
  __block CGFloat height = 0.0;
  
  [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *child = (UIView *)obj;
    if (child.hidden == NO) {
      height = MAX(height, child.frame.origin.y + child.frame.size.height);
    }
  }];
  
  frame.size.height = (height + margin);
  self.frame = frame;
}

@end