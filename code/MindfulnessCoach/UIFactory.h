//
//  UIFactory.h
//

#import <Foundation/Foundation.h>

@interface UIFactory : NSObject

// UIButton Generators
+ (UIButton *)buttonWithTitle:(NSString *)title;
+ (void)convertButtonToDestructiveStyle:(UIButton *)button;

// Styled UIViews
+ (UIView *)viewWithText:(NSString *)text imageName:(NSString *)imageName width:(CGFloat)width styled:(BOOL)styled;
+ (void)applyFakeGroupedTableViewStyleToView:(UIView *)view;
+ (void)removeFakeGroupedTableViewStyleToView:(UIView *)view;

// UITableView Header and Footer Generators
+ (UIView *)tableHeaderViewWithText:(NSString *)text
                          imageName:(NSString *)imageName
                              width:(CGFloat)width
                             styled:(BOOL)styled;
+ (UIView *)tableFooterViewWithButton:(NSString *)title;

// UITableViewCell Generators
+ (UITableViewCell *)cellWithDefaultStyleFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithDetailStyleFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithSubtitleStyleFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithTextFieldFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithTextViewFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithVariableHeightLabelFromTableView:(UITableView *)tableView withText:(NSString *)text;

+ (CGFloat)heightForVariableLabelTableViewCellWithText:(NSString *)text;

@end
