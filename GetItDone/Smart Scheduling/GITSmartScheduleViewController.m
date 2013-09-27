//
//  GITSmartScheduleViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/24/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITSmartScheduleViewController.h"
#import "NSDate+Utilities.h"

@implementation GITSmartScheduleViewController

- (IBAction)buttonSmartSchedule:(id)sender {
   
    //Find random date within the week
    //TODO: later this information will come from a form
    //TODO: later have 'restricted' hours to not even bother putting event in?
    int dayPeriod = 7;
    //below works when the method is in this class, but not when in category
    _randomDate =[NSDate randomTimeWithinDayPeriod:dayPeriod];
    
    
    //Make sure that time slot does not have a task
    //Assume event to be schedule has duration of 1 hour
    //TODO: Take in this info later
    [self isTimeSlotTakenWithDuration:1 andDate:_randomDate];
    
    //If time slot is taken, get another one
    if([self isTimeSlotTakenWithDuration:1 andDate:_randomDate])
    {
        //_randomDate = [NSDate findRandomTimeWithinDayPeriod:7];
    }
    //Else, schedule an event for this slot
    else
    {
        
    }
    
    //If not, ask user for feedback on this time
    //If they say no, get another one
    //If they say yes, add an event to the database with this time
}

-(bool)isTimeSlotTakenWithDuration:(int)duration andDate:(NSDate *)date
{
    //Right now, it only checks if anything is in that hour because it assumes a one hour duration
    //TODO: Fix this later
    
    //Get whole db
    //Loop through events and check start time
    //If start time hour = date's hour, return true for taken
    bool found = 0;
    _helper = [[GITDatebaseHelper alloc] init];
    [_helper printDatabase];
    return found;
}

@end
