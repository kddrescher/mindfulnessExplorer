//
//  ViewControllerComposite.m
//

#import "ViewControllerComposite.h"
#import "Action.h"
#import "ActivitiesViewController.h"
#import "ActivityEditViewController.h"
#import "ActionMenuViewController.h"
#import "AppConstants.h"
#import "AppDelegate.h"
#import "ButtonMenuViewController.h"
#import "Client.h"
#import "ExerciseEventEditViewController.h"
#import "HelpViewController.h"
#import "HomeViewController.h"
#import "ProgressViewController.h"
#import "RemindersEditViewController.h"
#import "SettingsViewController.h"
#import "UIView+VPDView.h"

@implementation ViewControllerComposite

#pragma mark - Lifecycle

/**
 *  initWithViewController
 */
- (id)initWithClient:(Client *)client viewController:(UIViewController *)viewController {
  self = [self init];
  if (self != nil) {
    _client = [client retain];
    _action = nil;
    
    // Don't retain the view controller so that we avoid a circular dependency.
    _viewController = viewController;

    // Register for notification when the action property is set
    [self addObserver:self forKeyPath:@"action" options:0 context:nil];

    _actionBlocks = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    // Since blocks are created on the stack by default, we have to move them over
    // to the heap so that we can then store them in an NSDictionary. 
    ActionSelectedBlock heapBlock = nil;
    
    // kActionTypePage
    heapBlock = [^(Action *action){
      WebViewController *webViewController = [[WebViewController alloc] initWithClient:self.client 
                                                                              filename:action.filename];
      
      webViewController.action = action;
      [self.viewController.navigationController pushViewController:webViewController animated:YES];
      [webViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypePage];
    [heapBlock release];

    // kActionTypeButtonMenu
    heapBlock = [^(Action *action) {
      ButtonMenuViewController *menuViewController = [[ButtonMenuViewController alloc] initWithClient:self.client];
      
      menuViewController.action = action;
      [self.viewController.navigationController pushViewController:menuViewController animated:YES];
      [menuViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeButtonMenu];
    [heapBlock release];
    
    // kActionTypeMenu
    heapBlock = [^(Action *action) {
      ActionMenuViewController *menuViewController = [[ActionMenuViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                              client:self.client];
      
      menuViewController.action = action;
      [self.viewController.navigationController pushViewController:menuViewController animated:YES];
      [menuViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeMenu];
    [heapBlock release];

    // kActionTypeDismissAndSetTabIndex
    heapBlock = [^(Action *action){
      NSInteger index = [[action userInfo] integerValue];
      // Ugh. This is a hack to bridge from the modal HomeViewController to the main tab bar controller.
      AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      appDelegate.tabBarController.selectedIndex = index;
      [self.viewController dismissViewControllerAnimated:NO completion:nil];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeDismissAndSetTabIndex];
    [heapBlock release];

    // kActionTypeEditActivity
    heapBlock = [^(Action *action){
      ActivityEditViewController *editViewController = [[ActivityEditViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                  client:self.client 
                                                                                                activity:nil];
      editViewController.action = action;
      [self presentModalNavigationControllerWithViewController:editViewController dismissTitle:nil];
      [editViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeEditActivity];
    [heapBlock release];
    
    // kActionTypeViewActivities
    heapBlock = [^(Action *action){
      ActivitiesViewController *activitiesViewController = [[ActivitiesViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client];
      activitiesViewController.action = action;
      
      [self.viewController.navigationController pushViewController:activitiesViewController animated:YES];
      [activitiesViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeViewActivities];
    [heapBlock release];
    
    // kActionTypeViewActivityProgress
    heapBlock = [^(Action *action){
      ProgressViewController *progressViewController = [[ProgressViewController alloc] initWithClient:self.client];
      progressViewController.action = action;
      [self.viewController.navigationController pushViewController:progressViewController animated:YES];
      [progressViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeViewActivityProgress];
    [heapBlock release];
    
    // kActionTypeEditExerciseEvent
    heapBlock = [^(Action *action){
      ExerciseEventEditViewController *exerciseEventEditViewController = [[ExerciseEventEditViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client];
      exerciseEventEditViewController.action = action;
      
      [self presentModalNavigationControllerWithViewController:exerciseEventEditViewController dismissTitle:NSLocalizedString(@"Done", nil)];
      [exerciseEventEditViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeEditExerciseEvent];
    [heapBlock release];
    
    // kActionTypeEditRandomReminders
    heapBlock = [^(Action *action){
      RemindersEditViewController *remindersEditViewController = [[RemindersEditViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                                             client:self.client 
                                                                                                           editMode:RemindersEditModeRandomReminders];
      remindersEditViewController.action = action;
      [self presentModalNavigationControllerWithViewController:remindersEditViewController dismissTitle:nil];
      [remindersEditViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeEditRandomReminders];
    [heapBlock release];
    
    // kActionTypeEditLogReminder
    heapBlock = [^(Action *action){
      RemindersEditViewController *remindersEditViewController = [[RemindersEditViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                                             client:self.client 
                                                                                                           editMode:RemindersEditModeLogReminder];
      remindersEditViewController.action = action;
      [self presentModalNavigationControllerWithViewController:remindersEditViewController dismissTitle:nil];
      [remindersEditViewController release];
    } copy];
    
    [_actionBlocks setObject:heapBlock forKey:kActionTypeEditLogReminder];
    [heapBlock release];
    
    // kActionTypeShowSettings
    heapBlock = [^(Action *action) {
      SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client];
      settingsViewController.action = action;
      [self.viewController.navigationController pushViewController:settingsViewController animated:YES];
      [settingsViewController release];
    } copy];

    [_actionBlocks setObject:heapBlock forKey:kActionTypeShowSettings];
    [heapBlock release];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [self removeObserver:self forKeyPath:@"action"];
  [_client release];
  [_action release];
  [_actionBlocks release];
  _viewController = nil;
  
  [super dealloc];
}

#pragma mark - KVO Observation

/**
 *  observeValueForKeyPath:ofObject:change:context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"action"]) {
    // Update our navigation title with the title of the action.
    if (self.viewController.title == nil || self.viewController.navigationItem.title == nil) {
      if (self.action.navigationTitle != nil) {
        self.viewController.title = self.action.navigationTitle;
      } else {
        self.viewController.title = self.action.title;
      }
    }
    
    // Add a Help button
    if (self.action.helpFilename != nil) {
      UIBarButtonItem *helpButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", nil)
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(handleHelpButtonTapped:)];
      self.viewController.navigationItem.rightBarButtonItem = helpButtonItem;
      [helpButtonItem release];
    }

    // Let the view controller react
    if ([self.viewController respondsToSelector:@selector(actionWasUpdated:)]) {
      [self.viewController performSelector:@selector(actionWasUpdated:) withObject:self.action];
    }
  }
}

#pragma mark - Event Handlers

/**
 *  handleHomeButtonTapped
 */
- (void)handleHomeButtonTapped:(id)sender {
  HomeViewController *homeViewController = [[HomeViewController alloc] initWithClient:self.client];
  homeViewController.action = [self.client rootActionForGroup:kActionGroupHome];
  
  [self presentModalNavigationControllerWithViewController:homeViewController dismissTitle:nil];
  [homeViewController release];
}

/**
 *  handleHelpButtonTapped
 */
- (void)handleHelpButtonTapped:(id)sender {
  NSString *helpFilename = self.action.helpFilename;
  if (helpFilename != nil) {
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithClient:self.client 
                                                                               filename:self.action.helpFilename];
    
    [self presentModalNavigationControllerWithViewController:helpViewController dismissTitle:nil];
    [helpViewController release];
  }
}

/**
 *  handleModalDismissButtonTapped
 */
- (void)handleModalDismissButtonTapped:(id)sender {
  [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Instance Methods

/**
 *  presentModalNavigationControllerWithViewController
 */
- (void)presentModalNavigationControllerWithViewController:(UIViewController *)viewController dismissTitle:(NSString *)dismissTitle {
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
  navigationController.navigationBar.tintColor = [AppConstants navigationBarTintColor];
  
  if (dismissTitle != nil) {
    UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:dismissTitle
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(handleModalDismissButtonTapped:)];
    viewController.navigationItem.leftBarButtonItem = dismissBarButtonItem;
    [dismissBarButtonItem release];
  }
  
  // We don't animate the HomeViewController.
  BOOL animate = ![viewController isKindOfClass:[HomeViewController class]];
  
  [self.viewController presentViewController:navigationController animated:animate completion:nil];
  
  [navigationController release];
}

/**
 *  performActionBlockForAction
 */
- (void)performActionBlockForAction:(Action *)action {
  ActionSelectedBlock actionBlock = [self.actionBlocks objectForKey:action.type];
  if (actionBlock != nil) {
    actionBlock(action);
  }
}

/**
 *  setBackButtonTitle
 */
- (void)setBackButtonTitle:(NSString *)title {
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:nil
                                                                    action:nil];
  self.viewController.navigationItem.backBarButtonItem = backButtonItem;
  [backButtonItem release];
}

/**
 *  actionWasUpdated
 */
- (void)actionWasUpdated:(Action *)action {
  // Intentionally left blank.
}

@end
