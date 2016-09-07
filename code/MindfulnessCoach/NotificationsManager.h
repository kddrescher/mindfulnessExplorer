//
//  NotificationsManager.h
//

#import <Foundation/Foundation.h>

typedef enum {
  ReminderTypeLogReminder = 0,      
  ReminderTypeRandomReminder
} ReminderType;

@class Client;

@interface NotificationsManager : NSObject

// Properties
@property(nonatomic, retain) Client *client;
@property(nonatomic, retain) UIApplication *application;

// Initializers
- (id)initWithClient:(Client *)client application:(UIApplication *)application;

// Instance Methods
- (NSDate *)nextNotificationDateFromDate:(NSDate *)referenceDate;
- (NSDate *)nextRandomNotificationDateFromDate:(NSDate *)referenceDate frequency:(NSCalendarUnit)frequency;

- (void)cancelNotificationsWithType:(NSString *)notificationType;
- (void)cancelAllNotifications;

- (void)debugDumpNotifications;

@end
