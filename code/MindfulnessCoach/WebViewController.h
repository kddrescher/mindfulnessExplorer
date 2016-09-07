//
//  WebViewController.h
//

#import "BaseViewController.h"
#import "PracticeViewController.h"

@class WebPage;

@interface WebViewController : BaseViewController<UIWebViewDelegate>

// Properties
@property(nonatomic, retain, readonly) WebPage *webPage;
@property(nonatomic, retain, readonly) UIWebView *webView;

// Initializers
- (id)initWithClient:(Client *)client filename:(NSString *)filename;

// Instance Methods
- (void)loadWebPage:(WebPage *)webPage;
- (void)showPracticeViewControllerForContent:(PracticeViewContent)viewContent title:(NSString *)title;

@end
