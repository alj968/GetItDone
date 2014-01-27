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
    //TODO: Test this method vigorously
    //Fetch the top time slot in the category
    NSArray *orderedTimeSlots = [self.helper fetchTimeSlotsOrderedByWeightForCategoryTitle:categoryTitle];
    
    //Get first time slot
    int i = 0;
    GITTimeSlot *timeSlot = [orderedTimeSlots objectAtIndex:i];
    //TODO: Later change this to take in day period from priority
    NSDate *dateSuggestion = [NSDate makeDateFromTimeSlot:timeSlot withinDayPeriod:7];
    
    //Check for overlap
    while([self isTimeSlotTakenWithDuration:duration andDate:dateSuggestion] && i < orderedTimeSlots.count)
    {
        //If overlap, get next slot down
        i++;
        timeSlot = [orderedTimeSlots objectAtIndex:i];
        //TODO: test this
        dateSuggestion = [NSDate makeDateFromTimeSlot:timeSlot withinDayPeriod:7];
    }
    //TODO: finish below 2 steps
    //See if i met the count (in which case time slot without overlap wasn't found)
    //Otherwise, suggest dateSuggestion
    return dateSuggestion;
}

/**
 Suggestions a random date (including time) that does not conflict with any existing event's dates.
 */
//TODO: Change this later to pick random time slot. TODO - add this to .h file
-(NSDate *)makeRandomTimeSuggestionForDuration:(NSNumber *)duration
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
