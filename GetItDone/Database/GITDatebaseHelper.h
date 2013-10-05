//
//  GITDatebaseHelper.h
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface GITDatebaseHelper : NSObject

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Forms/edits an event entity with given attributes and saves it to the database
 @param nsstring Title of event
 @param nsdate State date of event
 @param nsdate End date of event
 @param nsstring Specifies if event is a task or not (if task, can be rescheduled)
 @param event The event being edited (not application if event is being created)
 @return bool Returns true if event saved successfully, false otherwise
 */
- (BOOL) makeEventAndSaveWithTitle:(NSString *)title
                      andStartDate:(NSDate *)start
                        andEndDate:(NSDate *)end
                       andTaskBOOL:(NSString *)taskBOOL
                       andDuration:(NSString *)duration
                          forEvent:(Event *)event;

/**
 Gets all of the events in the database which occur on the given day
 @param nsdate The date selected from the calendar
 @return nsarray The array of events occuring on the selected day
 */
-(NSArray *) fetchEventsOnDay:(NSDate *)day;

/**
 Prints all of the contents of the database
 */
- (void) printDatabase;

/**
 TODO: Comment later, in progress
 */
- (BOOL)eventWithinDuration:(int)duration startingAt:(NSDate *)startTime;

/**
 Converts the duration to a number
 @param nsstring The duration of the event as a string
 @return nsnumber The duration of the event as a NSNumber
 */
- (NSNumber *)durationStringToNumber:(NSString *)durationString;

/**
 Converts the task to a number
 @param nsstring The task of the event as a string
 @return nsnumber The task of the event as a NSNumber
 */
- (NSNumber *)taskStringToNumber:(NSString *)taskString;

/**
 Converts the task to a number
 @param nsnumber The task of the event as a NSNumber
 @return nsstring The task of the event as a string
 */
-(NSString *)taskNumberToString:(NSNumber *)taskNumber;

@end
