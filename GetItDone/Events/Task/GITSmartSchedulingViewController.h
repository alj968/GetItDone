//
//  GITSmartSchedulingViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatebaseHelper.h"
#import "GITTimeSlotManager.h"

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
@property (nonatomic, strong) GITDatebaseHelper *helper;
/**
 The entity manager for time slot
 */
@property (nonatomic, strong) GITTimeSlotManager *timeSlotManager;
/**
 The title of the task in the notification
 */
@property (nonatomic, strong) NSString *taskTitle;
/**
 The time of the task in the notification
 */
@property (nonatomic, strong) NSDate *taskTime;
/**
 The category of the task in the notification
 */
@property (nonatomic, strong) NSString *categoryTitle;

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
 Responds to user actions. Adjusts the time slot tables according to the user action, and if neccessary, sets a notification for the time of a scheduled task.
 @param title The title of the task that was acted upon
 @param categoryTitle The title of the category of the task that was acted upon
 @param startTime The starting time of the task that was acted upon
 */
-(void)userActionTaken:(NSString *)userAction forTaskTitle:(NSString *)title categoryTitle:(NSString *)categoryTitle startTime:(NSDate *)startTime;
/**
 When the user gets a notification at the time of a task, the app delgate passes the notification to this view controller to handle the notification and the user's action from it
 @param localNotification The notification at the time of a task
 */
- (void)notificationReceived:(UILocalNotification *)localNotification;

@end
