//
//  NSString+VPDString.h
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface NSString (VPDString)

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)interval;
+ (NSString *)stringWithNotificationFrequency:(NotificationFrequency)frequency;

@end
