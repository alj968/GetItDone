//
//  GITSmartSchedulingViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatabaseHelper.h"
#import "GITTimeSlotManager.h"
#import "GITTask.h"
#import "GITTaskManager.h"

@interface GITSmartSchedulingViewController : UIViewController 

/**
 Random date found within a one week period of current date
 to be suggested
 TODO: Change this comment so it's not always one week period -- or remove?
 */
//@property (nonatomic, strong) NSDate *randomDate;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The entity manager for time slot
 */
@property (nonatomic, strong) GITTimeSlotManager *timeSlotManager;
/**
 The entity manager for task
 */
@property (nonatomic, strong) GITTaskManager *taskManager;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;

/**
 Suggestions a date for the task that does not conflict with any existing event's date, and is within the given day period
 Selects from the time slot table for that category, starting with the time slot with the top weight
 @param duration The length of the task for which a time slot must be found
 @param categoryTitle The category title for the task to be scheduled
 @param dayPeriod The number of days within which the date should be. (Priority used to determine this)
 @return Returns a smart scheduling suggestion for the task to be scheduled
 */
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod;

/**
 Asks the database to check if an existing event conflicts with the given date, for an task with the given duration.
 @param duration The duration of the task to be scheduled
 @param date The date of the task to be scheduled
 @return taken Returns true if the time slot conflicts with an existing event, false otherwise
 */
-(BOOL)isTimeSlotTakenWithDuration:(NSNumber *)duration andDate:(NSDate *)date;

/**
 Responds to a rejection. 
 Special case since task is not yet made, so cannot use "UserActionTakenForTask"
 Adjusts the time slot tables according to the user action.
 @param title The title of the task that was acted upon
 @param categoryTitle The title of the category of the task that was acted upon
 @param startTime The starting time of the task that was acted upon
 */
-(void)rejectionForTaskTitle:(NSString *)title categoryTitle:(NSString *)categoryTitle startTime:(NSDate *)startTime;
/**
 Responds to user actions. Adjusts the time slot tables according to the user action, and if neccessary, sets a notification for the time of a scheduled task.
 @param task The task the action was taken upon
 */
-(void)userActionTaken:(NSString *)userAction forTask:(GITTask *)task;
/**
 When the user gets a notification at the time of a task, the app delgate passes the notification to this view controller to handle the notification and the user's action from it
 @param localNotification The notification at the time of a task
 */
- (void)notificationReceived:(UILocalNotification *)localNotification;

@end
