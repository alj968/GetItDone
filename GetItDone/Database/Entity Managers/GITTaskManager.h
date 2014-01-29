//
//  GITTaskManager.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITDatebaseHelper.h"

/**
 This is the entity manager for Task. It is responsible for all business logic for task, and communicates with the database helper so the database helper can perform the requested CRUD operations.
 */
@interface GITTaskManager : NSObject

/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;

/**
 Fills in any missing required attributes (title or priority) and sends the information to the database helper so the helper can add the task to the database.
 @param title Title of event
 @param start State date of event
 @param description Description of event
 @param duration Duration, in minutes, of the event
 @param category Category of the event
 @param deadline Deadline - date before which the event must be scheduled (optional)
 @param priority Numeric rating of priority (optional)
 @param task If you are modifying an existing task, that task is passed in
 @return success Returns true if task saved successfully to database, false othewise
 */
- (BOOL) makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start description:(NSString *)description duration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task;

/**
 Validates relevant task attributes for the database.
 Ensures that duration is a positive integer,
 and that deadline is after current date.
 @param duration Duration of task
 @param deadline Deadline of task
 @param error The error found in validation
 @return errorMessage The message to be shown in an alert, giving details as to what information was not valid
 */
-(BOOL)isTaskInfoValidForDuration:(NSNumber *)duration deadline:(NSDate *)deadline error:(NSError **)error;

/**
 Translates the priority number into a day period, based on the relationship defined in the requirements
 @param priority The priority as a NSNumber
 @return Returns the number of days in the day period, as an int
 */
- (int)getDayPeriodForTaskPriority:(NSNumber *)priority;

@end
