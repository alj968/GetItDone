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

-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod
{
    //Assume all conflicts to start
    BOOL weekDayInDayPeriod = NO;
    BOOL overlap = YES;
    BOOL haveValidDateSuggestion = NO;
    
    //Set up loop var, timeSlot and dateSuggestion
    int i = 0;
    GITTimeSlot *timeSlot;
    NSDate *dateSuggestion;
    NSArray *orderedTimeSlots =[self.helper fetchTimeSlotsOrderedByWeightForCategoryTitle:categoryTitle];
    
    //Start looking for time slot that passes all the tests
    while((!weekDayInDayPeriod || overlap || !haveValidDateSuggestion) && i < orderedTimeSlots.count)
    {
        timeSlot = [orderedTimeSlots objectAtIndex:i];
        //Check if it's in the day period
        weekDayInDayPeriod = [NSDate isDayOfWeek:timeSlot.day_of_week WithinDayPeriod:dayPeriod ofDate:[NSDate date]];
        
        //If it didn't pass period test, move on to next slot
        if(!weekDayInDayPeriod)
        {
            i++;
        }
        //If it passed the day period test, move onto next test to check if there's overlap
        else
        {
            dateSuggestion = [NSDate dateFromTimeSlot:timeSlot withinDayPeriod:dayPeriod];
            overlap = [self isTimeSlotTakenWithDuration:duration andDate:dateSuggestion];
            //If it didn't pass overlap test, move on to next slot
            if(overlap)
            {
                i++;
            }
            //If no overlap, this is a valid date suggestion that passed both tests, so stop looking
            else
            {
                haveValidDateSuggestion = YES;
            }
        }
    }
    //When you leave this loop, either i surpassed the end of the time slots, or have valid date suggestion
    if(haveValidDateSuggestion)
    {
        return dateSuggestion;
    }
    else
    {
        //All date suggestions either aren't in day period, or conflict with existing event
        //TODO: Display alert here? Or do error protocol probably
        return NULL;
    }
}

/**
 Suggestions a random date (including time) that does not conflict with any existing event's dates.
 */
//TODO: Change this later to pick random time slot. TODO - add this to .h file
/*
-(NSDate *)makeRandomTimeSuggestionForDuration:(NSNumber *)duration
{
    //At least for now, always scheduling a task within the week (unless priority shortens that time period)
    int dayPeriod = 7;
    _randomDate =[NSDate randomTimeWithinDayPeriod:dayPeriod];
    
    //Loop until you find a time slot that's not taken
    // while([self isTimeSlotTakenWithDuration:duration andDate:_randomDate]);
    
    return _randomDate;
}*/

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
