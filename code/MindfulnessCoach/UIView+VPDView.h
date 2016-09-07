//
//  UIView+VPDView.h
//

#import <UIKit/UIKit.h>

@interface UIView (VPDView)

- (void)positionAboveView:(UIView *)reference margin:(CGFloat)margin;
- (void)positionBelowView:(UIView *)reference margin:(CGFloat)margin;
- (void)positionToTheRightOfView:(UIView *)reference margin:(CGFloat)margin;
- (void)positionToTheLeftOfView:(UIView *)reference margin:(CGFloat)margin;
- (void)positionAtTheBottomofView:(UIView *)reference margin:(CGFloat)margin;

- (void)alignLeftWithView:(UIView *)reference;
- (void)alignRightWithView:(UIView *)reference;
- (void)alignTopWithView:(UIView *)reference;
- (void)alignBottomWithView:(UIView *)reference;
- (void)alignVerticalWithView:(UIView *)reference;
- (void)alignHorizontalWithView:(UIView *)reference;

- (void)moveToPoint:(CGPoint)point;

- (void)moveToTopInParent;
- (void)moveToTopInParentWithMargin:(CGFloat)margin;

- (void)moveToBottomInParent;
- (void)moveToBottomInParentWithMargin:(CGFloat)margin;

- (void)moveToRightInParent;
- (void)moveToRightInParentWithMargin:(CGFloat)margin;

- (void)moveToLeftInParent;
- (void)moveToLeftInParentWithMargin:(CGFloat)margin;

- (void)centerHorizontallyInView:(UIView *)reference;
- (void)centerVerticallyInView:(UIView *)reference;

- (void)offsetYOriginBy:(CGFloat)delta;
- (void)resizeHeightBy:(CGFloat)delta;
- (void)resizeTo:(CGSize)size;

- (void)resizeHeightToContainSubviewsWithMargin:(CGFloat)margin;

@end
