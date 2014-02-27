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

//TODO: remove later?
+ (NSDate *)randomTimeWithinDayPeriod:(int)noOfDays {
    //Find a random number between 1 and noOfDaysa
    //This will be the number of days you're adding
    int randomNoDays = arc4random_uniform(noOfDays);
    //Find a random number between 1 and 23 for the hours you're adding
    int randomNoHrs = arc4random_uniform(23);
    
    //Start at today
    NSDate *today = [NSDate new];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //Figure what date components you should add to today to get to a new random date
    NSDateComponents *addComponents = [NSDateComponents new];
    [addComponents setDay:randomNoDays];
    [addComponents setHour:randomNoHrs];
    [addComponents setMinute:0];
    [addComponents setSecond:0];
    
    //Form the date by adding those components to today's date
    NSDate *randomDate = [gregorian dateByAddingComponents:addComponents
                                                    toDate:today options:0];
    
    //Set its hour and minutes to 0
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:randomDate];
    randomDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return randomDate;
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

+(NSDate *)dateFromTimeSlot:(GITTimeSlot *)timeSlot withinDayPeriod:(int)dayPeriod
{
    //Use today's date and the end date to establish range for possible suggestions
    NSDate *todaysDate = [NSDate date];
    NSDate *endDate = [self dateByAddingDayPeriod:dayPeriod toDate:todaysDate];
    
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

+ (BOOL)isDayOfWeek:(NSString *)dayOfWeek WithinDayPeriod:(NSInteger)dayPeriod ofDate:(NSDate *)date
{
    //If dayPeriod >= 6, every week day is automatically included since there will be at least one week, including date itself
    if(dayPeriod >= 6)
    {
        return YES;
    }
    else
    {
        //Get day of week of starting day
        NSString *aDayOfWeek = [self dayOfWeekStringFromDate:date];
        
        for(int i = 0; i <= dayPeriod; i++)
        {
            if([aDayOfWeek isEqualToString:dayOfWeek])
            {
                return YES;
            }
            else
            {
                //Go to the next day
                int aDayOfWeekInt = [self getIntValueForDayOfWeek:aDayOfWeek] + 1;
                aDayOfWeek = [self getStringForDayOfWeekIntValue:aDayOfWeekInt];
            }
        }
        //If you went through all days and didn't return yes yet, the weekday is not in the period
        return NO;
    }
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