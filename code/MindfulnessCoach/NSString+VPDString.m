//
//  NSString+VPDString.m
//

#import "NSString+VPDString.h"

@implementation NSString (VPDString)

/**
 *  stringWithTimeInterval
 */
+ (NSString *)stringWithTimeInterval:(NSTimeInterval)interval {
  NSInteger hours = floor(interval / 3600);
  NSInteger minutes = floor(interval / 60 - (hours * 60));
  
  NSString *hoursString = nil;
  if (hours == 1) {
    hoursString = [NSString stringWithFormat:@"%d %@", hours, NSLocalizedString(@"hour", nil)];
  } else if (hours > 1) {
    hoursString = [NSString stringWithFormat:@"%d %@", hours, NSLocalizedString(@"hours", nil)];
  }
  
  NSString *minutesString = nil;
  if (minutes == 1) {
    minutesString = [NSString stringWithFormat:@"%d %@", minutes, NSLocalizedString(@"minute", nil)];
  } else if (minutes > 1) {
    minutesString = [NSString stringWithFormat:@"%d %@", minutes, NSLocalizedString(@"minutes", nil)];
  }
  
  if (hoursString != nil && minutesString != nil) {
    return [NSString stringWithFormat:@"%@, %@", hoursString, minutesString];
  } else if (hoursString != nil) {
    return hoursString;
  } else {
    return minutesString;
  }
}

/**
 *  stringWithNotificationFrequency
 */
+ (NSString *)stringWithNotificationFrequency:(NotificationFrequency)frequency {
  NSString *string = nil;
  
  switch (frequency) {
    case NotificationFrequencyNone: {
      string = NSLocalizedString(@"None", nil);
      break;
    }
      
    case NotificationFrequencyOneTime: {
      string = NSLocalizedString(@"One Time", nil);
      break;
    }

    case NotificationFrequencyWeekly:{
      string = NSLocalizedString(@"Weekly", nil);
      break;
    }
      
    case NotificationFrequencyDaily: {
      string = NSLocalizedString(@"Daily", nil);
      break;
    } 
      
    case NotificationFrequencyMonthly: {
      string = NSLocalizedString(@"Monthly", nil);
      break;
    } 

    case NotificationFrequencyTwicePerDay: {
      string = NSLocalizedString(@"Twice a Day", nil);
      break;
    }
      
    case NotificationFrequencyThricePerDay: {
      string = NSLocalizedString(@"Three Times a Day", nil);
      break;
    }
      
    case NotificationFrequencyEveryOtherDay: {
      string = NSLocalizedString(@"Every Other Day", nil);
      break;
    }
  }
  
  return string;
}

@end
