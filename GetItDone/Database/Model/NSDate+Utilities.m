//
//  NSDate+Utilities.m
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

//TODO: Later check if these methods are still relevant, if not, remove.
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

- (NSDate *)dateWithTime:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    return [NSDate dateWithTime:year month:month day:day hour:0 minutes:0 seconds:0];
}

@end