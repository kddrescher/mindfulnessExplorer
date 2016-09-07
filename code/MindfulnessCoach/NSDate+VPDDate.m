//
//  NSDate+VPDDate.m
//

#import "NSDate+VPDDate.h"

@implementation NSDate (VPDDate)

#pragma mark - Class Methods

/**
 *  dateWithMonthsFromNow
 */
+ (NSDate *)dateWithMonthsFromNow:(NSInteger)months {
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setMonth:months];
    
  NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
  [components release];
  
  return date;
}

#pragma mark - Instance Methods

/**
 *  dateByAddingMonths
 */
- (NSDate *)dateByAddingMonths:(NSInteger)months {
  return [self dateByAddingMonths:months days:0 hours:0 minutes:0];
}

/**
 *  dateByAddingDays
 */
- (NSDate *)dateByAddingDays:(NSInteger)days{
  return [self dateByAddingMonths:0 days:days hours:0 minutes:0];
}

/**
 *  dateByAddingHours
 */
- (NSDate *)dateByAddingHours:(NSInteger)hours{
  return [self dateByAddingMonths:0 days:0 hours:hours minutes:0];
}

/**
 *  dateByAddingMinutes
 */
- (NSDate *)dateByAddingMinutes:(NSInteger)minutes{
  return [self dateByAddingMonths:0 days:0 hours:0 minutes:minutes];
}

/**
 *  dateByAddingMonths:days:hours:minutes
 */
- (NSDate *)dateByAddingMonths:(NSInteger)months days:(NSInteger)days hours:(NSInteger)hours minutes:(NSInteger)minutes {
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setMonth:months];
  [components setDay:days];
  [components setHour:hours];
  [components setMinute:minutes];
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *newDate = [calendar dateByAddingComponents:components toDate:self options:0];
  
  [components release];

  return newDate;
}

/**
 *  isBeforeDate
 */
- (BOOL)isBeforeDate:(NSDate *)date {
  return ([self compare:date] == NSOrderedAscending);
}

/**
 *  isAfterDate
 */
- (BOOL)isAfterDate:(NSDate *)date {
  return ([self compare:date] == NSOrderedDescending);
}

@end
