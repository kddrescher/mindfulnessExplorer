//
//  WebPage.m
//

#import "WebPage.h"
#import "AppConstants.h"

@implementation WebPage

#pragma mark - Lifecycle

/**
 *  initWithFilename
 */
- (id)initWithFilename:(NSString *)filename {
  self = [self init];
  if (self != nil) {
    _filename = [filename copy];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_filename release];
  [_HTML release];
  [_bodyCSSClass release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  baseURL
 */
- (NSURL *)baseURL {
  return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

/**
 *  HTML
 */
- (NSString *)HTML {
  if (_HTML == nil) {
    if (_filename != nil) {
      NSStringEncoding encoding;
      NSError *error = nil;
      NSString *pageContent = nil;
      
      // Load the page contents.
      NSString *filePath = [[NSBundle mainBundle] pathForResource:_filename ofType:nil];  
      if (filePath != nil) {  
        pageContent = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];  
      } 
      
      // TODO: Check against NSError instead.
      if (pageContent != nil) {
        // Load the HTML layout file.
        NSString *layoutPath = [[NSBundle mainBundle] pathForResource:kContentHTMLLayoutPath ofType:nil];
        NSString *layoutContent = [NSString stringWithContentsOfFile:layoutPath usedEncoding:&encoding error:&error];
        
        // Inject the body CSS class
        NSString *bodyClass = (_bodyCSSClass == nil ? @"default" : _bodyCSSClass);
        layoutContent = [layoutContent stringByReplacingOccurrencesOfString:kContentHTMLBodyClassPlaceholder withString:bodyClass];
        
        // Inject the page content into the layout.
        _HTML = [[layoutContent stringByReplacingOccurrencesOfString:kContentHTMLLayoutPlaceholder withString:pageContent] copy];
      }
    }
    
  }
  
  return _HTML;
}
@end
