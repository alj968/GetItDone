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
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                 minutes:(NSInteger)minutes
                 seconds:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minutes];
    [components setSecond:second];
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (NSDate *)dateWithTime:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    return [NSDate dateWithYear:year month:month day:day hour:0 minutes:0 seconds:0];
}

+ (NSDate *)randomTimeWithinDayPeriod:(int)noOfDays {
    //Find a random number between 1 and noOfDaysa
    //This will be the number of days you're adding
    int randomNoDays = arc4random_uniform(noOfDays);
    //Find a randon number between 1 and 23 for the hours you're adding
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

+ (NSString *)getDayOfWeekFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
}

+ (int)getMilitaryHourFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kGITDefintionDateFormat];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    return hour;
}

+(NSDate *)makeDateFromTimeSlot:(GITTimeSlot *)timeSlot withinDayPeriod:(int)dayPeriod
{
    //Use today's date and the end date to establish range for possible suggestions
    NSDate *todaysDate = [NSDate date];
    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:(dayPeriod*24*60*60)];
    
    //Get day of week and time of day from time slot
    NSString *dayOfWeek = timeSlot.day_of_week;
    NSNumber *timeOfDay = timeSlot.time_of_day;
    
    //Get current year
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear fromDate:[NSDate date]];
    int year = [components year];
    
    //Make a date that fits the requirements for day of week, hour and year
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeekday:[self getIntValueForDayOfWeek:dayOfWeek]];
    [comps setHour:[timeOfDay integerValue]];
    [comps setMinute:0];
    [comps setSecond:0];
    [comps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    
    //Check to see if the date is within the acceptable range. If not, add or subtract to it
    /**
     Note: Although "date" starts within the year, if the week includes a new year, and the day of the week is part of this new year, date will eventually reach it because of the dateByAddingTimeInterval method - TESTED.
     */
    while([date compare:todaysDate] == NSOrderedAscending || [date compare:endDate] == NSOrderedDescending)
    {
        //If it's earlier than today, add a week. Otherwise, subtract a week
        //TODO: In below two assignments of date, think about if it'll work to just add a week if the day period is different than a week
        if([date compare:todaysDate] == NSOrderedAscending)
        {
            date = [date dateByAddingTimeInterval:7*24*60*60];
        }
        else
        {
            date = [date dateByAddingTimeInterval:-7*24*60*60];
        }
    }
    return date;
}

/**
 Converts the day of week string into an integer according to iOS standards
 @param dayOfWeekString The day of the week as a string
 @return The integer value for that day of the week
 */
+ (int)getIntValueForDayOfWeek:(NSString *)dayOfWeekString
{
    if([dayOfWeekString isEqualToString:@"Sunday"])
    {
        return 1;
    }
    else if([dayOfWeekString isEqualToString:@"Monday"])
    {
        return 2;
    }
    else if([dayOfWeekString isEqualToString:@"Tuesday"])
    {
        return 3;
    }
    else if([dayOfWeekString isEqualToString:@"Wednesday"])
    {
        return 4;
    }
    else if([dayOfWeekString isEqualToString:@"Thursday"])
    {
        return 5;
    }
    else if([dayOfWeekString isEqualToString:@"Friday"])
    {
        return 6;
    }
    else if([dayOfWeekString isEqualToString:@"Saturday"])
    {
        return 7;
    }
    return 0;
}

@end