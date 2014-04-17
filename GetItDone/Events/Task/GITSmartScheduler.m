//
//  GITSmartScheduler.m
//  GetItDone
//
//  Created by Amanda Jones on 3/31/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITSmartScheduler.h"
#import "NSDate+Utilities.h"

@implementation GITSmartScheduler

#pragma mark - Constructors
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

- (GITTaskManager *)taskManager
{
    if(!_taskManager)
    {
        _taskManager = [[GITTaskManager alloc] init];
    }
    return _taskManager;
}

+ (instancetype) sharedScheduler
{
    static GITSmartScheduler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GITSmartScheduler alloc] init];
    });
    return instance;
}

#pragma  mark - Get smart scheduling suggestion

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
            /* Regarding excludingEvent being nil:
             Only way to reach this function is when you want a new suggestion for an edited task,
             or you're postponing a task.
             In the case of edit, if duration was changed (which is the only way to edit time-related aspect of a task), this method not called unless new duratin causes conflict, in which case you wouldn't want to exclude the edited-task because it's time is no longer a valid slot
             In the case of a postpone, you don't want to exclude the postpoed-event becuase you don't want to suggest the time slot it was already postponed in
             */
            overlap = ([self overlapWithinDuration:duration andDate:dateSuggestion excludingEvent:nil]);
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

#pragma mark - Check Overlap

-(BOOL)overlapWithinDuration:(NSNumber *)duration andDate:(NSDate *)date excludingEvent:(GITEvent *)event
{
    BOOL overlap = NO;
    //Check if there's overlap with GITEvents
    overlap = [self.helper overlapWithinDuration:duration startingAt:date excludingEvent:event];
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
-(void)handleDoForTask:(GITTask *)task
{
    [self.timeSlotManager adjustTimeSlotsForDate:task.start_time duration:task.duration categoryTitle:task.belongsTo.title userAction:kGITUserActionDo];
}

-(void)handlePostponeForTask:(GITTask *)task
{
    [self.timeSlotManager adjustTimeSlotsForDate:task.start_time duration:task.duration categoryTitle:task.belongsTo.title userAction:kGITUserActionPostpone];
    
    [self.helper increasePriorityForTask:task];
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


#pragma mark - UserActionDelegate methods
-(void)userActionViewController:(GITUserActionViewController *)controller finishedWithAcceptForTask:(GITTask *)task
{
    // Adjust time slots
    [self.timeSlotManager adjustTimeSlotsForDate:task.start_time duration:task.duration categoryTitle:task.belongsTo.title userAction:kGITUserActionAccept];
    
    // Schedule notification
    [self scheduleNotificationForTask:task];

    // Get access to root view controller (which is a nav controller) via app delegate
    GITAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *nav = (UINavigationController *)delegate.window.rootViewController;
    [nav dismissViewControllerAnimated:NO completion:nil];
    // Dimiss modal view
    [nav popToRootViewControllerAnimated:YES];
    // Pop to home screen
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)userActionViewController:(GITUserActionViewController *)controller finishedWithRejectForTaskTitle:(NSString *)title categoryTitle:(NSString *)categoryTitle startTime:(NSDate *)start duration:(NSNumber *)duration
{
    //Have time slot manager change appropriate time slots
    [self.timeSlotManager adjustTimeSlotsForDate:start duration:duration categoryTitle:categoryTitle userAction:kGITUserActionReject];
}

@end
