//
//  UIFactory.m
//
#import <QuartzCore/QuartzCore.h>

#import "UIFactory.h"
#import "AppConstants.h"
#import "UIView+VPDView.h"

@implementation UIFactory

#pragma mark - UIButton Generators

/**
 *  buttonWithTitle
 */
+ (UIButton *)buttonWithTitle:(NSString *)title { 
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  
  button.titleLabel.font = [AppConstants buttonFont];
  button.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
  
  CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
  CGFloat buttonWidth = MIN(titleSize.width + (kUIViewHorizontalMargin * 2), 320.0 - (kUIViewHorizontalMargin * 2));
  CGFloat buttonImageCapWidth = 10.0;
  CGFloat buttonImageCapHeight = 0.0;
  
  // There's an assumption here that the button height is equal to kUIHeightButton.
  UIImage *normalImage = [[UIImage imageNamed:@"buttonBackgroundGrayNormal"] stretchableImageWithLeftCapWidth:buttonImageCapWidth
                                                                                                 topCapHeight:buttonImageCapHeight];
  
  [button setBackgroundImage:normalImage forState:UIControlStateNormal];
  [button setTitle:title forState:UIControlStateNormal];
  
  [button setTitleColor:[AppConstants primaryTextColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  
  [button setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
  [button setTitleShadowColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateHighlighted];
  
  [button setFrame:CGRectMake(0.0, 0.0, buttonWidth, kUIHeightButton)];
  
  return button;
}

/**
 *  convertButtonToDestructiveStyle
 */
+ (void)convertButtonToDestructiveStyle:(UIButton *)button {
  CGFloat buttonImageCapWidth = 10.0;
  CGFloat buttonImageCapHeight = 0.0;
  
  UIImage *normalImage = [[UIImage imageNamed:@"buttonBackgroundRedNormal.png"] stretchableImageWithLeftCapWidth:buttonImageCapWidth
                                                                                                    topCapHeight:buttonImageCapHeight];
  
  [button setBackgroundImage:normalImage forState:UIControlStateNormal];
  
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  
  [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.0] forState:UIControlStateNormal];
  [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.0] forState:UIControlStateHighlighted];
}

#pragma mark - UIViews

/**
 *  viewWithText:imageName:styled
 */
+ (UIView *)viewWithText:(NSString *)text imageName:(NSString *)imageName width:(CGFloat)width styled:(BOOL)styled {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 0.0)];
  CGFloat verticalInset = (styled ? kUIViewVerticalMargin : 0);
  CGFloat horizontalInset = (styled ? kUIViewHorizontalMargin : 0);
  CGFloat contentHeight = verticalInset * 2;
  CGFloat labelVerticalOffset = verticalInset;
  
  if (imageName != nil) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [view addSubview:imageView];
    
    [imageView moveToTopInParentWithMargin:verticalInset];
    [imageView centerHorizontallyInView:view];
    
    contentHeight += imageView.frame.size.height;
    
    // Add some more margin if there's going to be a label below us
    if (text != nil) {
      contentHeight += kUIViewVerticalMargin;
      labelVerticalOffset += (imageView.frame.size.height + kUIViewVerticalMargin);
    }
    
    [imageView release];
  }
  
  CGSize constraintSize = CGSizeMake(width - (horizontalInset * 2), CGFLOAT_MAX);
  CGRect boundingRect = [text boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:[AppConstants textFont]}
                                               context:nil];
  CGSize labelSize = boundingRect.size;
  CGRect labelFrame = CGRectMake(horizontalInset, labelVerticalOffset, labelSize.width, labelSize.height);
  
  UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
  label.backgroundColor = [UIColor clearColor];
  label.font = [AppConstants textFont];
  label.numberOfLines = 0;
  label.text = text;
  label.textColor = [AppConstants primaryTextColor];
  
  if (text != nil) {
    [view addSubview:label];
    
    contentHeight += labelSize.height;
  }
  
  if (styled == YES) {
    [self applyFakeGroupedTableViewStyleToView:view];
  } else {
    label.layer.shadowColor = [UIColor whiteColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    label.layer.shadowRadius = 0.0;
    label.layer.shadowOpacity = 1.0;
  }
  
  [label release];
  [view resizeTo:CGSizeMake(width, contentHeight)];
  return [view autorelease];
}

/**
 *  applyFakeGroupedTableViewStyleToView
 */
+ (void)applyFakeGroupedTableViewStyleToView:(UIView *)view {
  view.backgroundColor = [UIColor whiteColor];
  view.layer.borderColor = [UIColor colorWithWhite:0.72 alpha:1.0].CGColor;
  view.layer.borderWidth = 1.0f;
  view.layer.cornerRadius = 8;
  // This has to be 'NO' for shadows to work.
  // view.layer.masksToBounds = YES;
  view.layer.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
  view.layer.shadowOffset = CGSizeMake(0.0, 1.0);
  view.layer.shadowRadius = 0;
  view.layer.shadowOpacity = 1.0;
}

/**
 *  removeFakeGroupedTableViewStyleToView
 */
+ (void)removeFakeGroupedTableViewStyleToView:(UIView *)view {
  view.backgroundColor = [UIColor clearColor];
  view.layer.borderColor = [UIColor clearColor].CGColor;
  view.layer.borderWidth = 0.0;
  view.layer.cornerRadius = 0;
  view.layer.shadowColor = [UIColor clearColor].CGColor;
  view.layer.shadowOffset = CGSizeZero;
  view.layer.shadowRadius = 0;
  view.layer.shadowOpacity = 0;
}

#pragma mark - UITableView Header and Footer Generators

/**
 *  tableHeaderViewWithText
 */
+ (UIView *)tableHeaderViewWithText:(NSString *)text
                          imageName:(NSString *)imageName
                              width:(CGFloat)width
                             styled:(BOOL)styled {
  UIView *textView = [self viewWithText:text imageName:imageName width:width styled:styled];
  CGRect wrapperFrame = CGRectMake(0.0, 0.0, 320.0, textView.frame.size.height + (kUIViewVerticalMargin * 2));
  UIView *wrapperView = [[UIView alloc] initWithFrame:wrapperFrame];
  
  [wrapperView addSubview: textView];
  [textView centerHorizontallyInView:wrapperView];
  [textView centerVerticallyInView:wrapperView];
  
  return [wrapperView autorelease];
}

/**
 *  tableFooterViewWithButton
 */
+ (UIView *)tableFooterViewWithButton:(NSString *)title {
  UIButton *button = [UIFactory buttonWithTitle:title];
  CGRect buttonFrame = button.frame;
  
  CGRect footerFrame = CGRectMake(0, 0, 320.0, buttonFrame.size.height + (kUIViewVerticalMargin * 2));
  UIView *footerView = [[UIView alloc] initWithFrame:footerFrame];
  
  [button resizeTo:CGSizeMake(footerFrame.size.width - (kUIViewHorizontalMargin * 2), buttonFrame.size.height)];
  
  button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  button.tag = kViewTagTableViewFooterButton;
  
  [footerView addSubview:button];
  [button centerHorizontallyInView:footerView];
  [button centerVerticallyInView:footerView];
  
  return [footerView autorelease];
}

#pragma mark - UITableViewCell Generators

/**
 *  cellWithDefaultStyleFromTableView
 */
+ (UITableViewCell *)cellWithDefaultStyleFromTableView:(UITableView *)tableView {
  static NSString *sDefaultCellIdentifier = @"DefaultCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sDefaultCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sDefaultCellIdentifier] autorelease];
    cell.accessibilityTraits = UIAccessibilityTraitButton;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [AppConstants tableCellTitleFont];
    cell.textLabel.textColor = [AppConstants primaryTextColor];
  }
  
  return cell;
}

/**
 *  cellWithDetailStyleFromTableView
 */
+ (UITableViewCell *)cellWithDetailStyleFromTableView:(UITableView *)tableView {
  static NSString *sDetailCellIdentifier = @"DetailCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sDetailCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sDetailCellIdentifier] autorelease];
    cell.accessibilityTraits = UIAccessibilityTraitButton;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.font = [AppConstants tableCellDetailFont];
    cell.textLabel.font = [AppConstants tableCellTitleFont];
    cell.textLabel.textColor = [AppConstants primaryTextColor];
  }
  
  return cell;
}

/**
 *  cellWithSubtitleStyleFromTableView
 */
+ (UITableViewCell *)cellWithSubtitleStyleFromTableView:(UITableView *)tableView {
  static NSString *sDetailCellIdentifier = @"SubtitleCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sDetailCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sDetailCellIdentifier] autorelease];
    cell.accessibilityTraits = UIAccessibilityTraitButton;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.font = [AppConstants tableCellDetailFont];
    cell.textLabel.font = [AppConstants tableCellTitleFont];
    cell.textLabel.textColor = [AppConstants primaryTextColor];
  }
  
  return cell;
}

/**
 *  cellWithTextFieldFromTableView
 */
+ (UITableViewCell *)cellWithTextFieldFromTableView:(UITableView *)tableView {
  static NSString *sTextFieldCellIdentifier = @"TextFieldCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sTextFieldCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sTextFieldCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIFont *textFieldFont = [AppConstants textFont];
    CGFloat kMagicXOrigin = 9.0;
    CGRect textFieldFrame = CGRectMake(kMagicXOrigin, 0, cell.contentView.frame.size.width - (kMagicXOrigin * 2), textFieldFont.lineHeight);
    UITextField *textField = [[UITextField alloc] initWithFrame:textFieldFrame];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    textField.backgroundColor = [UIColor clearColor];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.enablesReturnKeyAutomatically = YES;
    textField.font = textFieldFont;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [AppConstants primaryTextColor];
    textField.tag = kViewTagTableViewCellTextField;
    
    [cell.contentView addSubview:textField];
    [textField centerVerticallyInView:cell.contentView];
    
    [textField release];
  }
  
  return cell;
}

/**
 *  cellWithTextViewFromTableView
 */
+ (UITableViewCell *)cellWithTextViewFromTableView:(UITableView *)tableView {
  static NSString *sTextViewCellIdentifier = @"TextViewCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sTextViewCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sTextViewCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Magic numbers, sorry.
    CGFloat kMagicXOrigin = 4.0;
    CGFloat kMagixYOrigin = 8.0;
    CGFloat kMagicHeight = kUIHeightTableViewCellWithTextView;
    CGRect textViewFrame = CGRectMake(kMagicXOrigin, kMagixYOrigin, cell.contentView.frame.size.width - (kMagicXOrigin * 2), kMagicHeight - (kMagixYOrigin * 2));
    
    UITextView *textView = [[UITextView alloc] initWithFrame:textViewFrame];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.alwaysBounceHorizontal = NO;
    textView.alwaysBounceVertical = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [AppConstants textFont];
    textView.textColor = [AppConstants primaryTextColor];
    textView.tag = kViewTagTableViewCellTextView;
    
    [cell.contentView addSubview:textView];
    [textView release];
  }
  
  return cell;
}

/**
 *  cellWithVariableHeightLabelFromTableView:withText
 */
+ (UITableViewCell *)cellWithVariableHeightLabelFromTableView:(UITableView *)tableView withText:(NSString *)text {
  static NSString *sTextViewCellIdentifier = @"VariableHeightLabelCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sTextViewCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sTextViewCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [AppConstants textFont];
    label.numberOfLines = 0;
    label.textColor = [AppConstants primaryTextColor];
    label.tag = kViewTagTableViewCellVariableHeightLabel;
    
    [cell.contentView addSubview:label];
    [label release];
  }
  
  UILabel *label = (UILabel *)[cell.contentView viewWithTag:kViewTagTableViewCellVariableHeightLabel];
  CGSize constraintSize = CGSizeMake(280.0, CGFLOAT_MAX);
  CGRect boundingRect = [text boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:[AppConstants textFont]}
                                           context:nil];
  CGRect labelFrame = CGRectMake(kUIViewVerticalMargin, kUIViewHorizontalMargin, boundingRect.size.width, boundingRect.size.height);
  
  label.frame = labelFrame;
  label.text = text;
  
  return cell;
}

/**
 *  heightForVariableLabelTableViewCellWithText
 */
+ (CGFloat)heightForVariableLabelTableViewCellWithText:(NSString *)text {
  CGSize constraintSize = CGSizeMake(280.0, CGFLOAT_MAX);
  CGRect boundingRect = [text boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:[AppConstants textFont]}
                                           context:nil];
  
  return boundingRect.size.height + (kUIViewVerticalMargin * 2);
}

@end
