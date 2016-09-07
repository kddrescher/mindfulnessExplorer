//
//  SettingsViewController.m
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "Client.h"
#import "UIFactory.h"

@implementation SettingsViewController

#pragma mark - UITableViewDataSource Methods

/**
 *  numberOfSectionsInTableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return kTableViewSectionResetUserData + 1;
}

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

/**
 *  tableView:titleForFooterInSection
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (section == kTableViewSectionAnalytics) {
    return NSLocalizedString(@"Help improve this application by automatically sending daily diagnostics and usage data. "
                             "Diagnostic data may include location information. Although no one can see your personal data, "
                             "looking at overall trends helps us make better products.", nil);
  }
  
  return nil;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  switch (indexPath.section) {
    case kTableViewSectionAnalytics: {
      cell.textLabel.text = NSLocalizedString(@"Provide Anonymous Usage Data", nil);
      cell.textLabel.textAlignment = NSTextAlignmentLeft;
      
      if (self.client.isAuthorizedToRecordUsageData == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      }
      break;
    }
      
    case kTableViewSectionResetUserData: {
      cell.textLabel.text = NSLocalizedString(@"Reset All User Data", nil);
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      break;
    }
      
    case kTableViewSectionApplicationVersion: {
      cell = [UIFactory cellWithDetailStyleFromTableView:tableView];
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.accessibilityTraits = UIAccessibilityTraitNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = NSLocalizedString(@"Version", nil);
      
      NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
      NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", version, build];
      break;
    }
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case kTableViewSectionAnalytics: {
      self.client.authorizedToRecordUsageData = !self.client.isAuthorizedToRecordUsageData;
      UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
      if (self.client.isAuthorizedToRecordUsageData == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
      }
      break;
    }
      
    case kTableViewSectionResetUserData: {
      UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"All user data will be permanently deleted.", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:NSLocalizedString(@"Delete User Data", nil)
                                                      otherButtonTitles:nil];
      
      [actionSheet showInView:self.view];
      [actionSheet release];
      break;
    }
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate Methods

/**
 *  actionSheet:clickedButtonAtIndex
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate clearUserDataAndResetApplicationState];
  }
}

@end
