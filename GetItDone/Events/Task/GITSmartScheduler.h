//
//  GITSmartScheduler.h
//  GetItDone
//
//  Created by Amanda Jones on 3/31/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITUserActionViewController.h"
#import "GITTimeSlotManager+Private.h"
#import "GITEKEventManager.h"

@interface GITSmartScheduler : NSObject <GITUserActionDelegate>


/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The entity manager for time slot
 */
@property (nonatomic, strong) GITTimeSlotManager *timeSlotManager;
/**
 The entity manager for EKEvents
 */
@property (nonatomic, strong) GITEKEventManager *ekEventManager;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The entity manager for task
 */
@property (nonatomic, strong) GITTaskManager *taskManager;

+ (instancetype)sharedScheduler;

/**
 Suggests a date for the task that does not conflict with any existing event's date, and is within the given day period, and before the given deadline
 Selects from the time slot table for that category, starting with the time slot with the top weight
 @param duration The length of the task for which a time slot must be found
 @param categoryTitle The category title for the task to be scheduled
 @param dayPeriod The number of days within which the date should be. (Priority used to determine this)
 @param deadline The date before which the task must be completed (can be nil)
 @return Returns a date to be suggested that fits requirements dictated by priority and deadline, is the best choice for the given category according to the time slot table, and does not overlap with any existing events
 */
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod forDeadline:(NSDate *)deadline;

/**
 Asks the database to check if an existing event conflicts with the given date, for an task with the given duration.
 @param duration The duration of the task to be scheduled
 @param date The date of the task to be scheduled
@param event The event that the event-to-be-scheduled can overlap with. This is important in the case of edit. (E.g. if an appointment was originally 8-9, and the user wants to make it
 @return taken Returns true if the time slot conflicts with an existing event, false otherwise
 */
-(BOOL)overlapWithinDuration:(NSNumber *)duration andDate:(NSDate *)date excludingEvent:(GITEvent *)event;
/**
 Registers action with time slot manager
 @param task The task "done"
 */
-(void)handleDoForTask:(GITTask *)task;

/**
 Increases the priority of the task that was postponed, and registers action with time slot manager
 @param The task postponed
 */
-(void)handlePostponeForTask:(GITTask *)task;

@end
