//
//  NSDate+VPDDate.h
//

#import <Foundation/Foundation.h>

@interface NSDate (VPDDate)

// Class Methods
+ (NSDate *)dateWithMonthsFromNow:(NSInteger)months;

// Instance Methods
- (NSDate *)dateByAddingMonths:(NSInteger)months;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingHours:(NSInteger)hours;
- (NSDate *)dateByAddingMinutes:(NSInteger)minutes;
- (NSDate *)dateByAddingMonths:(NSInteger)months days:(NSInteger)days hours:(NSInteger)hours minutes:(NSInteger)minutes;

- (BOOL)isBeforeDate:(NSDate *)date;
- (BOOL)isAfterDate:(NSDate *)date;

@end
