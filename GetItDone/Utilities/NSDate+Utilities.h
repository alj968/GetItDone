//
//  NSDate+Utilities.h
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITTimeSlot.h"

/**
 A category on NSDate
 */
@interface NSDate (Utilities)

/**
 Makes an NSDate to be used when making an event
 @param year Year
 @param month Month
 @param weekday The weekday, as an integer (Sunday = 1)
 @param day Day
 @param hour Hour
 @param minutes Minutes
 @param second Second
 @return Date to be created
 */
+ (NSDate *)dateWithYear:(NSInteger)year
                       month:(NSInteger)month
                 weekday:(NSInteger)weekday
                         day:(NSInteger)day
                        hour:(NSInteger)hour
                     minutes:(NSInteger)minutes
                     seconds:(NSInteger)second;

/**
 Parses the date and returns the day of week of the date
 @param date The date from which the day of week needs to be extracted
 @return The day of week as a string
 */
+ (NSString *)dayOfWeekStringFromDate:(NSDate *)date;

/**
 Parses the date and returns the hour of the date (without minutes or seconds)
 @param date The date from which the hour needs to be extracted
 @return Returns the hour in military time as an integer
 */
+ (int)militaryHourFromDate:(NSDate *)date;

/**
 Forms a date within the day period from the given time slot.
 @param timeSlot The time slot to be used as the basis for the date (gives day of week and time)
 @param dayPeriod The number of days within which the date must occur
 @return Returns the date formed
 */
+(NSDate *)dateFromTimeSlot:(GITTimeSlot *)timeSlot withinDayPeriod:(int)dayPeriod;
/**
 Determines if the given day of the week and hour of day is within the given day period, starting at the given date.
 @param dayOfWeek The day of the week as a string
 @param hourOfDay The hour of the day as NSNumber
 @param dayPeriod The number of days for the day period as an integer
 @param date The date at which the day period begins
 @return Returns true if that day of week and hours occurs with the day period, false otherwise
 */
+ (BOOL)isDayOfWeek:(NSString *)dayOfWeek andHour:(NSNumber *)hourOfDay WithinDayPeriod:(NSInteger)dayPeriod ofDate:(NSDate *)date;
/**
 Using the given date, constructs a date with time equal to 12:00 am, with the year month and day of month matching that of the given date
 @param date The date which has the desired year, month and day of month
 @return Returns a date that matches the given date, except that the time is 12:00 am
 */
+ (NSDate *)dateAtBeginningOfDate:(NSDate *)date;
/**
 Using the given date, constructs a date with time equal to 12:00  pm, with the year month and day of month matching that of the given date
 @param date The date which has the desired year, month and day of month
 @return Returns a date that matches the given date, except that the time is 12:00 am of the next day
 */
+ (NSDate *)dateAtEndOfDate:(NSDate *)date;

@end
