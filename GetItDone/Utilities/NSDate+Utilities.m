//
//  NSDate+Utilities.m
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                 weekday:(NSInteger)weekday
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                 minutes:(NSInteger)minutes
                 seconds:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearForWeekOfYearCalendarUnit |NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    if(year && year != 0)
        [components setYear:year];
    if(month && month != 0)
        [components setMonth:month];
    if(weekday && weekday != 0)
        [components setWeekday:weekday];
    if(day && day != 0)
        [components setDay:day];
    if(hour)
        [components setHour:hour];
    if(minutes)
        [components setMinute:minutes];
    if(second)
        [components setSecond:second];
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (NSString *)dayOfWeekStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
}

+ (int)militaryHourFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kGITDefintionDateFormat];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    return hour;
}

+ (NSDate *)dateAtBeginningOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kGITDefintionDateFormat];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateAtEndOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kGITDefintionDateFormat];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    [components setHour:24];
    return [calendar dateFromComponents:components];
}

+(NSDate *)dateFromTimeSlot:(GITTimeSlot *)timeSlot withinDayPeriod:(int)dayPeriod
{
    //Use today's date and the end date to establish range for possible suggestions
    NSDate *todaysDate = [NSDate date];
    NSDate *endDate = [self dateByAddingDayPeriod:dayPeriod toDate:todaysDate];
    //Make it end of day
    endDate =[NSDate dateAtEndOfDate:endDate];
    
    //Get day of week and time of day from time slot
    NSString *dayOfWeek = timeSlot.day_of_week;
    NSNumber *timeOfDay = timeSlot.time_of_day;
    
    //Get current year
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear fromDate:[NSDate date]];
    int year = [components year];
    
    //Make a date that fits the requirements for day of week, hour and year
    NSDate *date = [self dateWithYear:year month:0 weekday:[self getIntValueForDayOfWeek:dayOfWeek] day:0 hour:[timeOfDay integerValue] minutes:0 seconds:0];
    
    //Check to see if the date is within the acceptable range. If not, add or subtract to it
    /**
     Note: Although "date" starts within the year, if the week includes a new year, and the day of the week is part of this new year, date will eventually reach it because of the dateByAddingTimeInterval method - TESTED.
     */
    while([date compare:todaysDate] == NSOrderedAscending || [date compare:endDate] == NSOrderedDescending)
    {
        //If it's earlier than today, add a week. Otherwise, subtract a week
        if([date compare:todaysDate] == NSOrderedAscending)
        {
            date = [self dateByAddingDayPeriod:7 toDate:date];
        }
        //if date is 3/20/14 at 19:00, it subtracts a week -why?!
        else
        {
            date = [self dateByAddingDayPeriod:-7 toDate:date];
        }
    }
    return date;
}

/**
 Adds/subtracts the given number of days to the given date to produce a new date.
 @param dayPeriod The number of days to be added/subtracted
 @param date The date used as the basis for calculations
 @return The new date formed
 */
+ (NSDate *)dateByAddingDayPeriod:(NSInteger)dayPeriod toDate:(NSDate *)date
{
    return [date dateByAddingTimeInterval:dayPeriod*24*60*60];
}

+ (BOOL)isDayOfWeek:(NSString *)dayOfWeek andHour:(NSNumber *)hourOfDay WithinDayPeriod:(NSInteger)dayPeriod ofDate:(NSDate *)date
{
    BOOL dayWithinPeriod = NO;
    
    //Get day for today's date
    NSDate *todaysDate = [NSDate date];
    NSString *todaysDayOfWeek = [self dayOfWeekStringFromDate:todaysDate];
    //Get hour for today's date
    NSDateComponents *todaysHourDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    NSInteger todaysHour = [todaysHourDateComponents hour];

    
    //Get day of week of starting day
    NSString *thisWeekDay = [self dayOfWeekStringFromDate:date];
    
    //Loop through all days of day period, trying to match it to desired day (dayOfWeek)
    for(int i = 0; i <= dayPeriod && dayWithinPeriod == NO; i++)
    {
        //Day I'm looking at (thisWeekDay) is same as desired day (dayOfWeek)
        if([thisWeekDay isEqualToString:dayOfWeek])
        {
            //Date I'm looking at (thisWeekDay) is same as today's day of week
            if([thisWeekDay isEqualToString:todaysDayOfWeek])
            {
                //Make sure time proposed after current hour
                if([hourOfDay integerValue] > todaysHour)
                {
                    dayWithinPeriod = YES;
                }
            }
            //Not today, so don't have to worry about hour
            else
            {
                dayWithinPeriod = YES;
            }
        }
        //Go to the next day
        int thisWeekDayInt = [self getIntValueForDayOfWeek:thisWeekDay] + 1;
        thisWeekDay = [self getStringForDayOfWeekIntValue:thisWeekDayInt];
    }
    return dayWithinPeriod;
}

/**
 Converts the day of week string into an integer according to iOS standards
 @param dayOfWeekString The day of the week as a string
 @return The integer value for that day of the week
 */
+ (int)getIntValueForDayOfWeek:(NSString *)dayOfWeekString
{
    if([dayOfWeekString isEqualToString:@"Sunday"])
        return 1;
    else if([dayOfWeekString isEqualToString:@"Monday"])
        return 2;
    else if([dayOfWeekString isEqualToString:@"Tuesday"])
        return 3;
    else if([dayOfWeekString isEqualToString:@"Wednesday"])
        return 4;
    else if([dayOfWeekString isEqualToString:@"Thursday"])
        return 5;
    else if([dayOfWeekString isEqualToString:@"Friday"])
        return 6;
    else if([dayOfWeekString isEqualToString:@"Saturday"])
        return 7;
    return 0;
}

/**
 Converts the day of week string into an integer according to iOS standards
 @param dayOfWeekString The day of the week as a string
 @return The integer value for that day of the week
 */
+ (NSString *)getStringForDayOfWeekIntValue:(int)dayOfWeekInt
{
    if(dayOfWeekInt == 1)
        return @"Sunday";
    else if(dayOfWeekInt == 2)
        return @"Monday";
    else if(dayOfWeekInt == 3)
        return @"Tuesday";
    else if(dayOfWeekInt == 4)
        return @"Wednesday";
    else if(dayOfWeekInt == 5)
        return @"Thursday";
    else if(dayOfWeekInt == 6)
        return @"Friday";
    else if(dayOfWeekInt == 7)
        return @"Saturday";
    return nil;
}

@end