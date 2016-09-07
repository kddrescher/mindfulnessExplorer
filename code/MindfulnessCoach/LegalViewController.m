//
//  LegalViewController.m
//

#import "LegalViewController.h"
#import "Client.h"
#import "AppConstants.h"
#import "WebPage.h"

@implementation LegalViewController

#pragma mark - Lifecycle

/**
 *  initWithClient:filename
 */
- (id)initWithClient:(Client *)client filename:(NSString *)filename {
    self = [super initWithClient:client filename:filename];
    if (self != nil) {
        self.navigationItem.title = NSLocalizedString(@"Software License Agreement", nil);
    }
    
    return self;
}

#pragma mark - Instance Methods

/**
 *  webView:shouldStartLoadWithRequest:navigationType
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *lastPathComponent = request.URL.path.lastPathComponent;
    BOOL shouldLoadRequest = NO;
    
    if ([lastPathComponent isEqualToString:kContentHTMLURLViewIntroductionScreen]) {
        self.title = NSLocalizedString(@"Mindfulness Coach", nil);
        
        WebPage *webPage = [[WebPage alloc] initWithFilename:kContentHTMLURLLegalIntroduction];
        [self loadWebPage:webPage];
        [webPage release];
    } else if ([lastPathComponent isEqualToString:kContentHTMLURLViewHomeScreen]) {
        self.client.viewedLegalScreens = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kExitingFromLegal" object:NULL];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        shouldLoadRequest = [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return shouldLoadRequest;
}
@end
