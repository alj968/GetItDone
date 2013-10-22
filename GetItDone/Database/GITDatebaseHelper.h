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

@interface GITDatebaseHelper : NSObject

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Forms/edits an event entity of type appointment with given attributes and saves it to the database
 Automatically makes task field NO (false)
 Description is an optional attribute so it may be null.
 @param nsstring Title of event
 @param nsdate State date of event
 @param nsdate End date of event
 @param nsstring Description of event
 @return bool Returns true if event saved successfully, false otherwise
 */
- (BOOL) makeAppointmentAndSaveWithTitle:(NSString *)title
                            andStartDate:(NSDate *)start
                              andEndDate:(NSDate *)end
                          andDescription:(NSString *)description
                          forAppointment:(Appointment *)appointment;

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


@end
