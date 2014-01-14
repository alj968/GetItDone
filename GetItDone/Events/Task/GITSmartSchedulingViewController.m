//
//  GITSmartSchedulingViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITSmartSchedulingViewController.h"
#import "NSDate+Utilities.h"

@implementation GITSmartSchedulingViewController

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

/**
 Suggestions a random date (including time) that does not conflict with any existing event's dates.
 */
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration
{
    //At least for now, always scheduling a task within the week (unless priority shortens that time period)
    int dayPeriod = 7;
    _randomDate =[NSDate randomTimeWithinDayPeriod:dayPeriod];
    
    //Loop until you find a time slot that's not taken
   // while([self isTimeSlotTakenWithDuration:duration andDate:_randomDate]);
    
    return _randomDate;
}

/**
 Asks the database to check if an existing event conflicts with the given date, for an task with the given duration.
 @param duration The duration of the task to be scheduled
 @param date The date of the task to be scheduled
 @return taken Returns true if the time slot conflicts with an existing event, false otherwise
 */
-(BOOL)isTimeSlotTakenWithDuration:(NSNumber *)duration andDate:(NSDate *)date
{
    BOOL found = 0;
    if([self.helper eventWithinDuration:duration startingAt:date])
    {
        found = YES;
    }
    else{
        found = NO;
    }
    return found;
}

@end
