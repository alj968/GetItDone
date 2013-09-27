//
//  NSDate+Utilities.m
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

//TODO: EDITING DATE NOT WORKING!!!!
//TODO: Later check if these first 2 methods are still relevant, if not, remove.
+ (NSDate *)dateWithTime:(NSInteger)year
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
    return [NSDate dateWithTime:year month:month day:day hour:0 minutes:0 seconds:0];
}

+ (NSDate *)randomTimeWithinDayPeriod:(int)noOfDays {
    //Find a random number between 1 and 7
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
    
    //randomDate = [self trimMinutesAndSecondsFromDate:randomDate];
    
    return randomDate;
}

- (NSDate *)trimMinutesAndSecondsFromDate:(NSDate *)dateToTrim
{
    //Set its minutes and seconds to 0
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:dateToTrim];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end