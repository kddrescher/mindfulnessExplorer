//
//  WebViewController.m
//

#import <MediaPlayer/MediaPlayer.h>
#import "WebViewController.h"
#import "Action.h"
#import "AppConstants.h"
#import "NSDictionary+SSToolkitAdditions.h"
#import "PhotosViewController.h"
#import "SongsViewController.h"
#import "WebPage.h"

#pragma mark - Private Interface

@interface WebViewController()
@property(nonatomic, retain) WebPage *webPage;
@end

@implementation WebViewController

#pragma mark - Lifecycle

/**
 *  initWithClient:filename
 */
- (id)initWithClient:(Client *)client filename:(NSString *)filename {
  self = [self initWithClient:client];
  if (self != nil) {
    _webPage = [[WebPage alloc] initWithFilename:filename];
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  imageView.contentMode = UIViewContentModeTopLeft;
  imageView.image = [UIImage imageNamed:@"backgroundGrayStripped.png"];
  
  [self.view addSubview:imageView];
  [imageView release];
  
  UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
  webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
  webView.backgroundColor = [UIColor clearColor];
  webView.delegate = self;
  
  [self.view addSubview:webView];
  _webView = [webView retain];
  
  // A UIWebView has a drop shadow on the top and bottom of it that gets diplayed when the user scrolls past the
  // scrollable area. This hack removes those drop shadows so that our "fake" background view looks proper.
  // http://stackoverflow.com/questions/1074320/remove-uiwebview-shadow
  for(UIView *webView in [[[_webView subviews] objectAtIndex:0] subviews]) { 
    if([webView isKindOfClass:[UIImageView class]]) { 
      webView.hidden = YES; 
    } 
  }  
  
  [webView release];
  
  if (self.webPage != nil) {
    [self loadWebPage:self.webPage];
  }
}

/**
 *  viewDidUnload
 */
- (void)viewDidUnload {
  [_webView setDelegate:nil];
  [_webView stopLoading];
  [_webView release];
  _webView = nil;
  
  [super viewDidUnload];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_webPage release];
  [_webView setDelegate:nil];
  [_webView stopLoading];
  [_webView release];
  
  [super dealloc];
}

#pragma mark - UIWebView Delegate Methods

/**
 *  webView:didFailLoadWithError
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  // Intentionally left blank.
}

/**
 *  webView:shouldStartLoadWithRequest:navigationType
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  BOOL shouldLoadRequest = NO;
  NSString *lastPathComponent = request.URL.path.lastPathComponent;

  if ([lastPathComponent isEqualToString:kContentHTMLURLGoToPage]) {
    // Requests that end with <kContentHTMLURLGoToPage#[filename]>
    // This seemingly redundant functionality is needed to allow for Javascript driven page changes
    // via the setting of window.location.href. When set via Javascript, the UIWebViewNavigationType is of
    // type "other", not "link clicked". Since auto-loading of web requests also come through as "other"
    // we need a way to differentiate them.
    NSString *filename = request.URL.fragment;
    WebViewController *webViewController = [[WebViewController alloc] initWithClient:self.client filename:filename];
    webViewController.title = (self.navigationItem.title != nil ? self.navigationItem.title : self.title);
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewSongsController]) {
    SongsViewController *songsController = [[SongsViewController alloc] initWithStyle:UITableViewStylePlain client:self.client];
    [self.navigationController pushViewController:songsController animated:YES];
    [songsController release];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewPhotosController]) {
    PhotosViewController *photosController = [[PhotosViewController alloc] initWithStyle:UITableViewStylePlain client:self.client];
    [self.navigationController pushViewController:photosController animated:YES];
    [photosController release];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewPracticePhotosController]) {
    [self showPracticeViewControllerForContent:kPracticeViewContentPhotos title:NSLocalizedString(@"My Picture", nil)];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewPracticeSongsController]) {
    [self showPracticeViewControllerForContent:kPracticeViewContentSongs title:NSLocalizedString(@"My Songs", nil)];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewPracticeEnvironmentController]) {
    [self showPracticeViewControllerForContent:kPracticeViewContentEnvironment title:NSLocalizedString(@"My Environment", nil)];
  } else if ([lastPathComponent isEqualToString:kContentHTMLURLPlayVideo]) {
    NSString *movieFilename = request.URL.fragment;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:movieFilename ofType:nil];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:player];
    [player release];
  } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    if ([request.URL.scheme isEqualToString:@"file"]) {
      // Requests that specify a normal HREF <filename.html?title=Custom+Title>
      NSDictionary *queryParameters = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
      NSString *filename = request.URL.lastPathComponent;
      WebViewController *webViewController = [[WebViewController alloc] initWithClient:self.client filename:filename];
      
      if ([queryParameters valueForKey:@"title"] != nil) {
        webViewController.title = NSLocalizedString([queryParameters valueForKey:@"title"], nil);
      } else {
        webViewController.title = self.title;
      }
      
      [self.navigationController pushViewController:webViewController animated:YES];
      [webViewController release];
    } else if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]) {
      // Open these links in Mobile Safari
      [[UIApplication sharedApplication] openURL:request.URL];
    }
  } else {
    // All other load requests can be handled by the UIWebView
    shouldLoadRequest = YES;
  }

  return shouldLoadRequest;
}

/**
 *  webViewDidFinishLoad
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  // Intentionally left blank.
}

/**
 *  webViewDidStartLoad
 */
- (void)webViewDidStartLoad:(UIWebView *)webView {
  // Intentionally left blank.
}

#pragma mark - Instance Methods

- (void)loadWebPage:(WebPage *)webPage {
  self.webPage = webPage;
  [self.webView loadHTMLString:webPage.HTML baseURL:webPage.baseURL];
}

/**
 *  showPracticeViewControllerForContent:title
 */
- (void)showPracticeViewControllerForContent:(PracticeViewContent)viewContent title:(NSString *)title {
  PracticeViewController *practiceController = [[PracticeViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                                                      client:self.client 
                                                                                 viewContent:viewContent];
  practiceController.title = title;
  [self presentModalNavigationControllerWithViewController:practiceController dismissTitle:NSLocalizedString(@"Done", nil)];
  [practiceController release];
}

@end
