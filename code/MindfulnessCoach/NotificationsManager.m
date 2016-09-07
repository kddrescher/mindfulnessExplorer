//
//  NotificationsManager.m
//

#import "NotificationsManager.h"
#import "Blackout.h"
#import "Client.h"
#import "AppConstants.h"
#import "NSDate+VPDDate.h"

@implementation NotificationsManager

#pragma mark - Lifecycle

/**
 *  initWithClient:application
 */
- (id)initWithClient:(Client *)client application:(UIApplication *)application {
  self = [self init];
  if (self != nil) {
    _client = [client retain];
    _application = [application retain];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_client release];
  [_application release];
  [super dealloc];
}

#pragma mark - Instance Methods

/**
 *  nextNotificationDateFromDate
 */
- (NSDate *)nextNotificationDateFromDate:(NSDate *)referenceDate {
  NSDate *currentDate = [NSDate date];
  
  // If we're later in time then the current date, then we
  // consider ourselves to be the next notification date.
  if ([referenceDate compare:currentDate] == NSOrderedDescending) {
    return referenceDate;
  }
  
  // If we're earlier in time then the current date, (ie: 
  // this date has already passed), then the next notification
  // date is 'tomorrow' at our given time.
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:1];
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *notificationDate = [calendar dateByAddingComponents:components toDate:referenceDate options:0];
  
  [components release];
  
  // NSLog(@"Next Notification Date: %@", notificationDate);
  
  return notificationDate;
}

/**
 *  nextRandomNotificationDateFromDate:frequency
 */
- (NSDate *)nextRandomNotificationDateFromDate:(NSDate *)referenceDate frequency:(NSCalendarUnit)frequency {
  NSMutableArray *validTimeslots = [[NSMutableArray alloc] initWithCapacity:25];
  
  // Initial valid timeslots are every 15 minutes between 9:00am and 9:00pm, specified in seconds since midnight.
  NSTimeInterval nineAM = 32400;
  NSTimeInterval ninePM = 75600;
  NSTimeInterval fifteenMinutes = 900;
  NSTimeInterval timeslot = nineAM;
  NSCalendar *calendar = [NSCalendar currentCalendar];
  [calendar setTimeZone:[NSTimeZone localTimeZone]];
  NSArray *blackouts = [[self.client fetchedResultsControllerForBlackouts] fetchedObjects];
  
  while (timeslot <= ninePM) {
    BOOL isBlackedOut = NO;
    
    // This is rather brute-force, but it's highly unlikely that we'll have so many blackout periods for this
    // to realistically be a performance bottleneck. Maybe I'll regret saying that... 
    for (Blackout *blackout in blackouts) {
      NSDateComponents *startComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                      fromDate:blackout.startDate];
      NSDateComponents *endComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                    fromDate:blackout.endDate];
      
      NSTimeInterval startInterval = [startComponents hour] * 60 * 60 + [startComponents minute] * 60;
      NSTimeInterval endInterval = [endComponents hour] * 60 * 60 + [endComponents minute] * 60;
        
      // Normal case is that start interval is less than end interval.
      // i.e.: 10:15am -> 2:00pm
      if (startInterval <= endInterval) {
        // We're blacked out if the current interval is between the start and end intervals
        isBlackedOut = (timeslot >= startInterval && timeslot <= endInterval);
      } else {
        // Otherwise, we have a wrapped blackout
        // i.e.: 9:30pm -> 7:00am
        isBlackedOut = (timeslot >= startInterval || timeslot <= endInterval);
      }
      
      if (isBlackedOut) {
        break;
      }
    }
    
    if (isBlackedOut == NO) {
      [validTimeslots addObject:[NSNumber numberWithDouble:timeslot]];
    }
    
    timeslot += fifteenMinutes;
  }
  
  // 'validTimeslots' is now an array of NSNumbers, each of which represents the seconds-from-midnight that
  // a notification is allowed to fire. By default, we'll set up the next notification date to be 'tomorrow'
  // at a randomly chosen time.
  NSUInteger randomIndex = arc4random() % [validTimeslots count];
  NSTimeInterval selectedTimeslot = [[validTimeslots objectAtIndex:randomIndex] doubleValue];

  // Our reference date starts at 00:00am
  NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
                                             fromDate:referenceDate];
  [components setHour:0];
  [components setMinute:0];
  [components setSecond:0];
    
  // Create a base notification date that represents 'today' but with the randomly chosen time. 
  NSDate *nextNotificationDate = [NSDate dateWithTimeInterval:selectedTimeslot sinceDate:[calendar dateFromComponents:components]];
  
  // Based on the frequency passed in, advance the date either a random number of days, weeks or months
  NSUInteger randomRange = 7;
  if (frequency == NSWeekCalendarUnit) {
    randomRange = 14;
  } else if (frequency == NSMonthCalendarUnit) {
    // February is getting shafted. Months with 31 days are getting truncated. Life is simpler.
    randomRange = 30;
  }
  
  NSUInteger additionalDays = (arc4random() % randomRange) + 1;
  nextNotificationDate = [nextNotificationDate dateByAddingDays:additionalDays];
  
  // NSLog(@"Next Random Date: %@ (Days added: %d)", nextNotificationDate, additionalDays);
  [validTimeslots release];
  
  return nextNotificationDate;
}

/**
 *  cancelNotificationsWithType
 */
- (void)cancelNotificationsWithType:(NSString *)notificationType {
  NSArray *notifications = self.application.scheduledLocalNotifications;
  // NSLog(@"Total number of local notifications: %i", [notifications count]);
  
  for (UILocalNotification *notification in notifications) {
    NSDictionary *info = notification.userInfo;
    NSString *type = [info valueForKey:kLocalNotificationTypeKey];
    
    if ([notificationType isEqualToString:type]) {
      // NSLog(@"Cancelling local notification...");
      [self.application cancelLocalNotification:notification];
    }
  }
}

/**
 *  cancelAllNotifications
 */
- (void)cancelAllNotifications {
  self.application.scheduledLocalNotifications = nil;
}

/**
 *  debugDumpNotifications
 */
- (void)debugDumpNotifications {
  NSArray *notifications = self.application.scheduledLocalNotifications;
  
  NSLog(@"Notifications count: %d", [notifications count]);
  [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSNotification *notification = (NSNotification *)obj;
    NSDictionary *info = notification.userInfo;
    NSString *type = [info objectForKey:kLocalNotificationTypeKey];
    NSLog(@"Notification type: %@", type);
  }];
}

@end
