//
//  NSDate+Utilities.h
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A category on NSDate
 */
@interface NSDate (Utilities)

/**
 Makes an NSDate to be used when making an event
 @param year Year
 @param month Month
 @param day Day
 @param hour Hour
 @param minutes Minutes
 @param second Second
 @return Date to be created
 */
+ (NSDate *)dateWithYear:(NSInteger)year
                       month:(NSInteger)month
                         day:(NSInteger)day
                        hour:(NSInteger)hour
                     minutes:(NSInteger)minutes
                     seconds:(NSInteger)second;
/**
 Makes an NSDate with the given info, automatically setting the time to be 12:00 AM
 @param year Year
 @param month Month
 @param day Day
 @return Date to be created
 */
+ (NSDate *)allDayDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
/**
 Makes a random NSDate within the given number of days from today.
 @param noOfDays Date interval in which to make the random date
 @return The random date created
 */
+ (NSDate *)randomTimeWithinDayPeriod:(int)noOfDays;
//TODO: Also allow this to make an event on the half hour?
/**
 Takes in a NSDate and sets its minutes and seconds component to 0 so the 
 time is on the hour
 @param dateToTrim The date from which to trim the minutes and seconds
 @return The date that now has a time on the hour
 */
+ (NSDate *)trimMinutesAndSecondsFromDate:(NSDate *)dateToTrim;

@end
