//
//  GITSmartSchedulingViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITSmartSchedulingViewController.h"
#import "NSDate+Utilities.h"
//TODO - make sure every class has pragma marks ,and no more imports than they need
@implementation GITSmartSchedulingViewController

#pragma mark - Set up
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

#pragma mark - Make Time Suggestion
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod forDeadline:(NSDate *)deadline
{
    //Assume all conflicts to start
    BOOL weekDayInDayPeriod = NO;
    BOOL overlap = YES;
    BOOL haveValidDateSuggestion = NO;
    
    //Set up timeSlot and dateSuggestion
    GITTimeSlot *timeSlot;
    NSDate *dateSuggestion;
    NSArray *orderedTimeSlots =[self.helper fetchTimeSlotsOrderedByWeightForCategoryTitle:categoryTitle];
    
    //Start looking for time slot that passes all the tests
    for(int i = 0; i < orderedTimeSlots.count && !haveValidDateSuggestion; i++)
    {
        timeSlot = [orderedTimeSlots objectAtIndex:i];
        
        //Check if the preferred time slot it's in the day period
        weekDayInDayPeriod = [NSDate isDayOfWeek:timeSlot.day_of_week andHour:timeSlot.time_of_day WithinDayPeriod:dayPeriod ofDate:[NSDate date]];
        
        //If it passed the day period test, move onto next test to check if there's overlap
        if(weekDayInDayPeriod)
        {
            dateSuggestion = [NSDate dateFromTimeSlot:timeSlot withinDayPeriod:dayPeriod];
            overlap = ([self overlapWithinDuration:duration andDate:dateSuggestion]);
            //If no overlap, this is a valid date suggestion that passed both tests, so stop looking
            if(!overlap)
            {
                //If it passed the overlap test, and there's a deadline, check if the date is before the deadline
                if(!deadline || ([dateSuggestion compare:deadline] == NSOrderedAscending))
                {
                    haveValidDateSuggestion = YES;
                }
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

#pragma mark - Check Overlap
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

#pragma mark - Handle user actions taken
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

//TODO - Add "abandon" as option at time of task
-(void)handlePostponeForTask:(GITTask *)task
{
    [self.helper increasePriorityForTask:task];
   
    NSDate *newSuggestion = [self makeTimeSuggestionForDuration:task.duration andCategoryTitle:task.belongsTo.title withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:task.priority] forDeadline:task.deadline];
    
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

#pragma mark - Alert View
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:kGITAlertTimeSuggestion])
    {
        if (buttonIndex == 1)
        {
            //[self acceptSuggestion];
        }
        else if(buttonIndex == 2)
        {
           // [self rejectSuggestion];
        }
        else if(buttonIndex == 3)
        {
           // [self manuallyScheduleTask];
        }
        else if(buttonIndex == 4)
        {
            //handle Cancel
        }
    }
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
