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

#pragma  mark - Beginning smart scheduling methods

-(void)smartScheduleTaskWithTitle:(NSString *)taskTitle duration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle description:(NSString *)description priority:(NSNumber *)priority deadline:(NSDate *)deadline
{
    // Store information into member variables
    _taskTitle = taskTitle;
    _duration = duration;
    _categoryTitle = categoryTitle;
    _description = description;
    _priority = priority;
    _deadline = deadline;
    
    // Get smart scheduling suggestion
    [self makeSmartSchedulingSuggestionForDuration:_duration categoryTitle:_categoryTitle priority:_priority forDeadline:_deadline];
}

/**
 Makes smart scheduling suggestion for a new task. If a suggestion cannot be made, displays error alert.
 */
- (void)makeSmartSchedulingSuggestionForDuration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle priority:(NSNumber *)priority forDeadline:(NSDate *)deadline
{
    // Get day period for priority
    int dayPeriod = [self.taskManager getDayPeriodForTaskPriority:priority];
    
    // Get suggested time to do task
    _dateSuggestion = [self makeTimeSuggestionForDuration:duration andCategoryTitle:categoryTitle withinDayPeriod:dayPeriod forDeadline:deadline];
    
    // Display date suggestion
    if(_dateSuggestion)
    {
        [self showTimeSuggestionAlertWithDate:_dateSuggestion];
    }
    
    // Display Error
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"All time slots for the appropriate time period overlap with existing event. Please make room in your schedule, lower the priority, or change the deadline, and then try again." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Generating and Showing Smart Scheduling Suggestion
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod forDeadline:(NSDate *)deadline
{
    // Assume all conflicts to start
    BOOL weekDayInDayPeriod = NO;
    BOOL overlap = YES;
    BOOL haveValidDateSuggestion = NO;
    
    // Set up timeSlot and dateSuggestion
    GITTimeSlot *timeSlot;
    NSDate *dateSuggestion;
    NSArray *orderedTimeSlots =[self.helper fetchTimeSlotsOrderedByWeightForCategoryTitle:categoryTitle];
    
    //Start looking for time slot that passes all the tests
    for(int i = 0; i < orderedTimeSlots.count && !haveValidDateSuggestion; i++)
    {
        timeSlot = [orderedTimeSlots objectAtIndex:i];
        
        // Check if the preferred time slot it's in the day period
        weekDayInDayPeriod = [NSDate isDayOfWeek:timeSlot.day_of_week andHour:timeSlot.time_of_day WithinDayPeriod:dayPeriod ofDate:[NSDate date]];
        
        // If it passed the day period test, move onto next test to check if there's overlap
        if(weekDayInDayPeriod)
        {
            dateSuggestion = [NSDate dateFromTimeSlot:timeSlot withinDayPeriod:dayPeriod];
            overlap = ([self overlapWithinDuration:duration andDate:dateSuggestion]);
            //If no overlap, this is a valid date suggestion that passed both tests, so stop looking
            if(!overlap)
            {
                // If it passed the overlap test, and there's a deadline, check if the date is before the deadline
                if(!deadline || ([dateSuggestion compare:deadline] == NSOrderedAscending))
                {
                    haveValidDateSuggestion = YES;
                }
            }
        }
    }
    
    // When you leave this loop, either i surpassed the end of the time slots, or have valid date suggestion
    if(haveValidDateSuggestion)
    {
        return dateSuggestion;
    }
    else
    {
        return nil;
    }
}

/**
 Displays the time suggestion and allows the user to click buttons to accept, reject or cancel the suggestion.
 @param date The date to be suggested
 */
-(void)showTimeSuggestionAlertWithDate:(NSDate *)date
{
    NSString *randomDateString = [self.formatter stringFromDate:date];
    //TODO - figure out if i want to do all this
    //NSDate *endDate = [date dateByAddingTimeInterval:(60*[_duration intValue])];
    // NSString *endDateString = [self.formatter stringFromDate:endDate];
    
    // NSString *messageString = [NSString stringWithFormat:@"%@ - %@",randomDateString, endDateString];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: kGITAlertTimeSuggestion
                                                   message: randomDateString
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Accept",@"Reject",@"I'll choose my own time",nil];
    [alert show];
}

//TODO - add in button 4 here, cancel and handle what happens if it came from a postpone!
#pragma mark - Alert View
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:kGITAlertTimeSuggestion])
    {
        if (buttonIndex == 1)
        {
            [self acceptSuggestion];
        }
        else if(buttonIndex == 2)
        {
            [self rejectSuggestion];
        }
        else if(buttonIndex == 3)
        {
            [self manuallyScheduleTask];
        }
        else if(buttonIndex == 4)
        {
            //handle Cancel
        }
    }
}

#pragma mark - Post-suggestion Actions
- (void)acceptSuggestion
{
    _task = [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_dateSuggestion description:_description duration:_duration categoryTitle:_categoryTitle deadline:_deadline priority:_priority forTask:_task];
    
    if(_task)
    {
        //Have smart scheduler handle smart scheduling-related actions resulting from the accept
        [self userActionTaken:kGITUserActionAccept forTask:_task];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Faile" message:@"Could not save task. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

/**
 Called when the user rejects a smart scheduling suggestion.
 Generates a new smart scheduling suggestion and displays it.
 */
- (void) rejectSuggestion
{
    // Have smart scheduler handle smart scheduling-related actions resulting from the accept
    [self rejectionForTaskTitle:_taskTitle categoryTitle:_categoryTitle startTime:_dateSuggestion duration:_duration];
    
    // Make new suggestion
    [self makeSmartSchedulingSuggestionForDuration:_duration categoryTitle:_categoryTitle priority:_priority forDeadline:_deadline];
}

/**
 Called when the user requests to manually schedule a task after seeing the smart scheduling suggestion.
 */
-(void) manuallyScheduleTask
{
    //Count as reject
    [self rejectionForTaskTitle:_taskTitle categoryTitle:_categoryTitle startTime:_dateSuggestion duration:_duration];
    
    //Let user manually schedule
    //TODO - check this!! - doesn't work
    [self performSegueWithIdentifier:kGITSeguePushManualTask sender:self];
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

/**
 Responds to a rejection.
 Special case since task is not yet made, so cannot use "UserActionTakenForTask"
 Adjusts the time slot tables according to the user action.
 */
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
