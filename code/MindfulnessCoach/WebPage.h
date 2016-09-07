//
//  WebPage.h
//

#import <Foundation/Foundation.h>

@interface WebPage : NSObject

// Properties
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *HTML;
@property(nonatomic, copy) NSString *bodyCSSClass;
@property(nonatomic, retain, readonly) NSURL *baseURL;

// Initializers
- (id)initWithFilename:(NSString *)filename;

@end
