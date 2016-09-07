//
//  BaseLogEditViewController.m
//

#import "BaseLogEditViewController.h"
#import "EmailBuilder.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

@implementation BaseLogEditViewController

#pragma mark - Lifecycle

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.isEditingExistingLogEntry) {
    UIView *footerView = nil;
    
    if ([MFMailComposeViewController canSendMail]) {
      footerView = [UIFactory tableFooterViewWithButton:NSLocalizedString(@"Email Log Entry", nil)];
      UIButton *emailButton = (UIButton *)[footerView viewWithTag:kViewTagTableViewFooterButton];
      [emailButton addTarget:self action:@selector(handleEmailLogEntryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
      
      UIButton *deleteButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Delete Log Entry", nil)];
      [UIFactory convertButtonToDestructiveStyle:deleteButton];
      [deleteButton addTarget:self action:@selector(handleDeleteLogEntryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
      
      [footerView addSubview:deleteButton];
      [deleteButton resizeTo:emailButton.frame.size];
      [deleteButton alignLeftWithView:emailButton];
      [deleteButton positionBelowView:emailButton margin:kUIViewVerticalMargin];
      
      [footerView resizeHeightBy:deleteButton.frame.size.height + kUIViewVerticalMargin];
    } else {
      footerView = [UIFactory tableFooterViewWithButton:NSLocalizedString(@"Delete Log Entry", nil)];
      UIButton *deleteButton = (UIButton *)[footerView viewWithTag:kViewTagTableViewFooterButton];
      [UIFactory convertButtonToDestructiveStyle:deleteButton];
      [deleteButton addTarget:self action:@selector(handleDeleteLogEntryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.tableView.tableFooterView = footerView;
  }
}

#pragma mark - Message Handlers

/**
 *  handleEmailLogEntryButtonTapped
 */
- (void)handleEmailLogEntryButtonTapped:(id)sender {
  NSString *alertTitle = NSLocalizedString(@"Email Log Entry", nil);
  NSString *alertMessage = NSLocalizedString(@"To protect your privacy, send this email only to yourself at a secure "
                                             "personal account. Do not send this email to your healthcare provider or "
                                             "to anyone else.", nil);
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                  message:alertMessage
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"Continue", nil), nil];
  [alert show];
  [alert release];
}

/**
 *  handleDeleteLogEntryButtonTapped
 */
- (void)handleDeleteLogEntryButtonTapped:(id)sender {
  NSString *actionSheetTitle = NSLocalizedString(@"Are you sure you want to permanently delete this log entry?", nil);
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:NSLocalizedString(@"Delete Log Entry", nil)
                                                  otherButtonTitles:nil];
  
  [actionSheet showFromTabBar:self.tabBarController.tabBar];
  [actionSheet release];
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

/**
 *  mailCmoposeController:didFinishWithResult:error
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate Methods

/**
 *  actionSheet:clickedButtonAtIndex
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [super handleCancelButtonTapped:nil];
    [self.managedObject.managedObjectContext deleteObject:self.managedObject];
  }
}

#pragma mark - UIAlertViewDelegate Methods

/**
 *  alertView:clickedButtonAtIndex
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1 && self.emailBuilder) {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setSubject:self.emailBuilder.subject];
    [mailComposeViewController setMessageBody:self.emailBuilder.body isHTML:NO];
    
    [self presentViewController:mailComposeViewController animated:YES completion:nil];
    [mailComposeViewController release];
  }
}

@end
