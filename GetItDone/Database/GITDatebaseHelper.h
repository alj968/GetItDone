//
//  GITDatebaseHelper.h
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITEvent.h"
#import "GITAppointment.h"
#import "GITTask.h"
#import "GITCategory.h"
#import "GITTimeSlot.h"

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
 Description is an optional attribute so it may be null
 @param title Title of event
 @param start State date of event
 @param end End date of event
 @param description Description of event
 @param appointment If you are modifying an existing apointment, that appointment is passed in
 @return Returns true if event saved successfully, false otherwise
 */
- (BOOL)makeAppointmentAndSaveWithTitle:(NSString *)title
                               startDate:(NSDate *)start
                                 endDate:(NSDate *)end
                             description:(NSString *)description
                          forAppointment:(GITAppointment *)appointment;
/**
 Forms/edits an event entity of type task with given attributes and saves it to the database
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
- (BOOL)makeTaskAndSaveWithTitle:(NSString *)title
                        startDate:(NSDate *)start
                          endDate:(NSDate *)end
                      description:(NSString *)description
                         duration:(NSNumber *)duration
                         category:(GITCategory *)category
                         deadline:(NSDate *)deadline
                         priority:(NSNumber *)priority
                          forTask:(GITTask *)task;
/**
 Creates a category entity with the given name.
 @return Returns true if category saved successfully, false otherwise
 */
- (BOOL)makeCategoryWithTitle:(NSString *)title;
/**
 Adds a time slot table, with one slot for each hour of the day, for the provided category
 @param category The category the time slot table will correspond to
 @return Returns true if time slot table added successfully, false otherwise
 */
- (void)makeTimeSlotTableForCategoryTitle:(NSString *)title;
/**
 Deletes the specified event from the database
 @return Returns true if event deleted successfully, false otherwise
 */
- (BOOL)deleteEventFromDatabase:(GITEvent *)event;
/**
 Gets all of the events in the database which occur on the given day
 @param day The date selected from the calendar
 @return The array of events occuring on the selected day
 */
- (NSArray *)fetchEventsOnDay:(NSDate *)day;
/**
 Gets all the events in the database which occur during the month
 of the given day
 @param date The date that specfies what month to get events for
 @return The array of events occuring in the month of the date given
 */
- (NSArray *)fetchEventsInMonth:(NSDate *)date;
/**
 Retrives the category with the given title from the database. Since title is unique, this fetched objects array shoudl only have one item in it - the category which we are looking for
 @param title The title of the category to be looked up
 @return The category found for the given title
 */
- (GITCategory *)fetchCategoryWithTitle:(NSString *)title;
/**
 Fetches all entities of the given type
 @param entityType The type of entity to fetch
 @return All entities of that type in the database
 */
-(NSArray *)fetchEntitiesOfType:(NSString *)entityType;
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
 For a given entity type, checks if an entity with the given title is already in the database.
 @param entityType The entity type as a string
 @param title The title of the entity
 @return Returns true if entity of that type and name already exists, false otherwise
 */
- (BOOL)checkIfEntityOfType:(NSString *)entityType existsWithName:(NSString *)title;

@end
