//
//  GITTimeSlotManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/24/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITTimeSlotManager.h"

@implementation GITTimeSlotManager

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

-(void)adjustTimeSlotsForDate:(NSDate *)startingDate andCategoryTitle:(NSString *)categoryTitle forUserAction:(NSString *)action
{
    //Figure out by how much to change time slots
    int changeBy = [self getChangeByNumberForAction:action];
    
    //Figure out what main time slot is from startingDate
    GITTimeSlot *mainTimeSlot = [self.helper fetchTimeSlotForDate:startingDate andCategoryTitle:categoryTitle];
    
    //Loop through all time slots, and compare it with the above time slot, to determine if it's weight should be changed
    NSArray *categoryTimeSlots = [self.helper fetchTimeSlotsOrderedByWeightForCategoryTitle:categoryTitle];
    
    for(int i = 0; i < categoryTimeSlots.count; i++)
    {
        GITTimeSlot *aTimeSlot = [categoryTimeSlots objectAtIndex:i];
        if([self isTimeSlot:mainTimeSlot AtSameTimeAs:aTimeSlot] && [self isTimeSlot:mainTimeSlot OnSameDayAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are on the same day, within the same time group
        if([self isTimeSlot:mainTimeSlot OnSameDayAs:aTimeSlot] && [self isTimeSlot:mainTimeSlot InSameTimeGroupAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are at the same time, within the same day group
        if([self isTimeSlot:mainTimeSlot AtSameTimeAs:aTimeSlot] && [self isTimeSlot:mainTimeSlot InSameDayGroupAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are on the same day
        if([self isTimeSlot:mainTimeSlot OnSameDayAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are at the same time
        if([self isTimeSlot:mainTimeSlot AtSameTimeAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are in the same time group, and the same day group
        if([self isTimeSlot:mainTimeSlot InSameTimeGroupAs:aTimeSlot] && [self isTimeSlot:mainTimeSlot InSameDayGroupAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are on in the same day group
        if([self isTimeSlot:mainTimeSlot InSameDayGroupAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
        //They are in the same time group
        if([self isTimeSlot:mainTimeSlot InSameTimeGroupAs:aTimeSlot])
        {
            [self.helper changeWeightForTimeSlot:aTimeSlot byAmount:changeBy];
        }
    }
}

/**
 Looks at the user action taken and uses this to determine by how much the relevant time slots should be incremented or decremented
 @return Returns how much to change the relevant time slots by
 */
-(int)getChangeByNumberForAction:(NSString *)action
{
    int changeBy = 0;
    if([action isEqualToString:kGITUserActionAccept])
    {
        changeBy = 1;
        
    }
    else if([action isEqualToString:kGITUserActionReject])
    {
        changeBy = -1;
    }
    else if([action isEqualToString:kGITUserActionDo])
    {
        changeBy = 2;
    }
    else if([action isEqualToString:kGITUserActionPostpone])
    {
        changeBy = -2;
    }
    return changeBy;
}

/**
 Determines if the two given time slots have the same time of day
 @param firstTimeSlot The first time slot for comparison
 @param secondTimeSlot The second time slot for comparison
 @return Returns true if the time slots have the same time of day, false otherwise
 */
-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSLot AtSameTimeAs:(GITTimeSlot *)secondTimeSlot
{
    BOOL sameTime = false;
    if([firstTimeSLot.time_of_day isEqualToNumber:secondTimeSlot.time_of_day])
    {
        sameTime = true;
    }
    return sameTime;
}

/**
 Determines if the two given time slots have the same day of the week
 @param firstTimeSlot The first time slot for comparison
 @param secondTimeSlot The second time slot for comparison
 @return Returns true if the time slots have the same day of the week, false otherwise
 */
-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot OnSameDayAs:(GITTimeSlot *)secondTimeSlot
{
    BOOL sameDay = false;
    if([firstTimeSlot.day_of_week isEqualToString:secondTimeSlot.day_of_week])
    {
        sameDay = true;
    }
    return sameDay;
}

/**
 Determines if the two given time slots are in the same time group,
 using previously defined time groups that break the hours of the day into groups
 @param firstTimeSlot The first time slot for comparison
 @param secondTimeSlot The second time slot for comparison
 @return Returns true if the time slots are in the same time group, false otherwise
 */
-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot InSameTimeGroupAs:(GITTimeSlot *)secondTimeSlot
{
    BOOL sameTimeGroup = false;
    NSNumber *time1 = firstTimeSlot.time_of_day;
    NSNumber *time2 = secondTimeSlot.time_of_day;
    
    NSArray *earlyMorning = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6],[NSNumber numberWithInt:7],[NSNumber numberWithInt:8], nil];
    NSArray *lateMorning = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:9],[NSNumber numberWithInt:10],[NSNumber numberWithInt:11], nil];
    NSArray *earlyAfternoon = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:12],[NSNumber numberWithInt:13],[NSNumber numberWithInt:14], nil];
    NSArray *lateAfternoon = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:15],[NSNumber numberWithInt:16],[NSNumber numberWithInt:17], nil];
    NSArray *evening = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:18],[NSNumber numberWithInt:19],[NSNumber numberWithInt:20], nil];
    NSArray *night = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:21],[NSNumber numberWithInt:22],[NSNumber numberWithInt:23], nil];
    NSArray *lateNight = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], nil];
    NSArray *weeHours = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5], nil];
    
    NSArray *timeGroups = [[NSArray alloc] initWithObjects:earlyMorning, lateMorning, earlyAfternoon, lateAfternoon, evening, night, lateNight, weeHours, nil];
    
    for(int i = 0; i < [timeGroups count]; i++)
    {
        NSArray *currentTimeGroup = [timeGroups objectAtIndex:i];
        if([currentTimeGroup containsObject:time1] && [currentTimeGroup containsObject:time2])
        {
            sameTimeGroup = true;
        }
    }
    return sameTimeGroup;
}

/**
 Determines if the two given time slots are in the same day group,
 using previously defined day groups that break the days of the week into groups
 @param firstTimeSlot The first time slot for comparison
 @param secondTimeSlot The second time slot for comparison
 @return Returns true if the time slots are in the same day group, false otherwise
 */
-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot InSameDayGroupAs:(GITTimeSlot *)secondTimeSlot
{
    BOOL sameDayGroup = false;
    NSString *day1 = firstTimeSlot.day_of_week;
    NSString *day2 = secondTimeSlot.day_of_week;
    
    NSArray *weekendDays = [[NSArray alloc] initWithObjects:@"Saturday",@"Sunday", nil];
    NSArray *weekDays = [[NSArray alloc ] initWithObjects:@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday", nil];
    
    NSArray *dayGroups = [[NSArray alloc] initWithObjects:weekendDays, weekDays, nil];
    
    for(int i = 0; i < [dayGroups count]; i++)
    {
        NSArray *currentDayGroup = [dayGroups objectAtIndex:i];
        if([currentDayGroup containsObject:day1] && [currentDayGroup containsObject:day2])
        {
            sameDayGroup = true;
        }
    }
    return sameDayGroup;
}

@end
