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
 Makes a random NSDate within the given number of days from today.
 @param noOfDays Date interval in which to make the random date
 @return The random date created
 */
+ (NSDate *)randomTimeWithinDayPeriod:(int)noOfDays;

@end
