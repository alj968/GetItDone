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

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

-(GITTimeSlotManager *)timeSlotManager
{
    if(!_timeSlotManager)
    {
        _timeSlotManager = [[GITTimeSlotManager alloc] init];
    }
    return _timeSlotManager;
}

- (GITTaskManager *)taskManager
{
    if(!_taskManager)
    {
        _taskManager = [[GITTaskManager alloc] init];
    }
    return _taskManager;
}


- (GITEKEventManager *)ekEventManager
{
    if(!_ekEventManager)
    {
        _ekEventManager = [[GITEKEventManager alloc] init];
    }
    return _ekEventManager;
}

-(NSDateFormatter *)formatter
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:kGITDefintionDateFormat];
    }
    return _formatter;
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
        
        //Check if the preferred time slot it's in the day period
        weekDayInDayPeriod = [NSDate isDayOfWeek:timeSlot.day_of_week andHour:timeSlot.time_of_day WithinDayPeriod:dayPeriod ofDate:[NSDate date]];
        
        //If it didn't pass period test, move on to next slot
        if(!weekDayInDayPeriod)
        {
            i++;
        }
        //If it passed the day period test, move onto next test to check if there's overlap
        else
        {
            dateSuggestion = [NSDate dateFromTimeSlot:timeSlot withinDayPeriod:dayPeriod];
            overlap = ([self overlapWithinDuration:duration andDate:dateSuggestion]);
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
        return nil;
    }
}

-(BOOL)overlapWithinDuration:(NSNumber *)duration andDate:(NSDate *)date
{
    BOOL overlap = NO;
    //Check if there's overlap with GITEvents
    overlap = [self.helper overlapWithinDuration:duration startingAt:date];
    //If overlap found, return
    if(overlap)
    {
        return YES;
    }
    //If no overlap with GITEvents found, check for overlap with EKEvents
    else
    {
        //Check for overlap with ek events
        return [self.ekEventManager overlapWithEKEventForDuration:duration andDate:date];
    }
}

-(void)userActionTaken:(NSString *)userAction forTask:(GITTask *)task
{
    //Have time slot manager change appropriate time slots
    [self.timeSlotManager adjustTimeSlotsForDate:task.start_time duration:task.duration categoryTitle:task.belongsTo.title userAction:userAction];
    
    //If action is accept, make notification for task
    if([userAction isEqualToString:kGITUserActionAccept])
    {
        [self scheduleNotificationForTask:task];
    }
    if([userAction isEqualToString:kGITUserActionPostpone])
    {
        [self handlePostponeForTask:task];
    }
}

-(void)handlePostponeForTask:(GITTask *)task
{
    [self.helper increasePriorityForTask:task];
    
    NSDate *newSuggestion = [self makeTimeSuggestionForDuration:task.duration andCategoryTitle:task.belongsTo.title withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:task.priority]];
    
    if(newSuggestion)
    {
        NSString *randomDateString = [self.formatter stringFromDate:newSuggestion];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: kGITAlertTimeSuggestion
                                                       message: randomDateString
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Accept",@"Reject",@"I'll choose my own time",nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error"
                                                       message: @"All time slots for the appropriate time period overlap with existing event. Please make room in your schedule, lower the priority, or change the deadline, and then try again."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }

}

-(void)rejectionForTaskTitle:(NSString *)title categoryTitle:(NSString *)categoryTitle startTime:(NSDate *)startTime duration:(NSNumber *)duration;
{
    //Have time slot manager change appropriate time slots
    [self.timeSlotManager adjustTimeSlotsForDate:startTime duration:duration categoryTitle:categoryTitle userAction:kGITUserActionReject];
}

#pragma mark - Notifications
- (void)scheduleNotificationForTask:(GITTask *)task
{
    //Delete any existing notifications (important if this was an edited task)
    [self.helper deleteNotificationsForEvent:task];
    
    //Make notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil)
        return;
    localNotification.fireDate = task.start_time;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.alertBody = [NSString stringWithFormat:@"%@ starts now.",task.title];
    localNotification.alertAction = @"slide to do or postpone task";
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    /*
     Note: Cannot store NSManagedObjected in dict for userInfo - userInfo can only take plist types
     So, going to get the URI from the object, and then serealize it for the user info
     */
    NSURL *uri = [[task objectID] URIRepresentation];
    NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:uri];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:uriData,@"uriData", nil];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
