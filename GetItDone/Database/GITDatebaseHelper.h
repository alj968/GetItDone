//
//  GITDatebaseHelper.h
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Appointment.h"
#import "Task.h"

/**
 This is a helper class for the database. It serves as the intermediary between view controllers and the database.
 */
@interface GITDatebaseHelper : NSObject

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;
/**
 Forms/edits an event entity of type appointment with given attributes and saves it to the database
 Automatically makes task field NO (false)
 Description is an optional attribute so it may be null.
 @param title Title of event
 @param start State date of event
 @param end End date of event
 @param description Description of event
 @param appointment If you are modifying an existing apointment, that appointment is passed in
 @return Returns true if event saved successfully, false otherwise
 */
- (BOOL) makeAppointmentAndSaveWithTitle:(NSString *)title
                            startDate:(NSDate *)start
                              endDate:(NSDate *)end
                          description:(NSString *)description
                          forAppointment:(Appointment *)appointment;
/**
 Forms/edits an event entity of type task with given attributes and saves it to the database
 Automatically makes task field YES (true)
 Description, deadline, and priority are optional attributes so they may be null.
 @param title Title of event
 @param start State date of event
 @param description Description of event (optional)
 @param duration Duration, in minutes, of the event
 @param category Category of the event
 @param deadline Deadline - date before which the event must be scheduled (optional)
 @param priority Numeric rating of priority (optional)
 @param task If you are modifying an existing task, that task is passed in
 @return Returns true if event saved successfully, false otherwise
 */
- (BOOL) makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start description:(NSString *)description duration:(NSNumber *)duration category:(NSString *)category deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(Task *)task;
/**
 Gets all of the events in the database which occur on the given day
 @param day The date selected from the calendar
 @return The array of events occuring on the selected day
 */
-(NSArray *) fetchEventsOnDay:(NSDate *)day;
/**
 Gets all the events in the database which occur during the month
 of the given day
 @param date The date that specfies what month to get events for
 @return The array of events occuring in the month of the date given
 */
-(NSArray *) fetchEventsInMonth:(NSDate *)date;
/**
 Prints all of the contents of the database
 */
- (void) printDatabase;
/**
 Loops through database to see if any existing event's duration conflicts with the duration of 
 the generated random event's duration. Returns NO if no conflict.
 @param duration Duration of the event, in minutes
 @param startTime The random date generated. This method will add the duration to this to make
 a date interval for the random date
 @return Returns NO if no overlapping event or if one event ends when another starts.
 Otherwise, returns YES.
 */
- (BOOL)eventWithinDuration:(NSNumber *)duration startingAt:(NSDate *)startTime;

/**
 Converts the duration to a number
 @param durationString The duration of the event as a string
 @return The duration of the event as a NSNumber
 */
- (NSNumber *)durationStringToNumber:(NSString *)durationString;

@end
