//
//  EmailBuilder.h
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@class Activity;

@interface EmailBuilder : NSObject

// Properties
@property(nonatomic, retain) Activity *activity;
@property(nonatomic, retain) NSDateFormatter *dateFormatter;

@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *body;

// Initializers
- (id)initWithActivity:(Activity *)activity;

// Instance
- (NSString *)bodyWithActivity:(Activity *)activity;

@end
