//
//  ExerciseViewController.m
//

#import "ExerciseViewController.h"
#import "Activity.h"
#import "ActivityEditViewController.h"
#import "Exercise.h"
#import "AppConstants.h"

@implementation ExerciseViewController

#pragma mark - Lifecycle

/**
 *  initWithNibName
 */
- (id)initWithClient:(Client *)client exercise:(Exercise *)exercise {
  self = [super initWithClient:client filename:exercise.filename];
  if (self != nil) {
    _exercise = [exercise retain];
    
    self.navigationItem.title = exercise.title;
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_exercise release];
  
  [super dealloc];
}

#pragma mark - UIWebView Delegate Methods

/**
 *  webView:shouldStartLoadWithRequest:navigationType
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  BOOL shouldLoadRequest = NO;
  NSString *lastPathComponent = request.URL.path.lastPathComponent;

  if ([lastPathComponent isEqualToString:kContentHTMLURLNewActivity]) {
    ActivityEditViewController *editViewController = [[ActivityEditViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                client:self.client 
                                                                                              activity:nil];
    editViewController.action = self.action;
    [editViewController setActivityExercise:self.exercise];
    [self presentModalNavigationControllerWithViewController:editViewController dismissTitle:nil];
    [editViewController release];
  } else {
    shouldLoadRequest = [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
  }
  
  return shouldLoadRequest;
}

@end
