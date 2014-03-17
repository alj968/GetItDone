//
//  GITiCalendarEventManager.h
//  GetItDone
//
//  Created by Amanda Jones on 3/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITiCalendarEvent.h"
#import <EventKit/EventKit.h>

/**
 This is the manager for all EKEvents imported from iOS's Calendar app. It is responsible for all communication with the event store.
 */
@interface GITEKEventManager : NSObject

/**
 The iCalendar's event store
 */
@property (nonatomic, strong) EKEventStore *eventStore;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The EKEvent which needs to be deleted
 */
@property (nonatomic, strong) EKEvent *eventToDelete;

/**
 Deletes the given event from the iOS Calendar
 Asks for permission before deleting from iOS Calendar
 @param ekEvent The EKEvent to be deleted
 @return Returns true if successfully deleted, false otherwise
 */
-(void)deleteiCalendarEvent:(EKEvent *)ekEvent;
/**
 Fetches all EKEvents in the iOS Calendar within the given date range
 @param start The beginning date
 @param end The end date
 @return The array of events within the date range
 */
-(NSArray *)fetchiCalendarEventsFrom:(NSDate *)start until:(NSDate *)end;
/**
 Fetches all EKEvents in the iOS Calendar on the day of the given date
 @param date The date, with the day on which all events must occur to be returned
 @return The array of events on theh day of the date given
 */
-(NSArray *)fetchiCalendarEventsOnDay:(NSDate *)date;
/**
 Checks if any EKEvents overlaps with an event starting at the given date with the given duration
 @param rStart The start date of the event which shouldn't overlap with any EKEvents
 @param duration The duration of the event which shouldn't overlap with any EKEvents
 @return Returns true if there is an EKEvent whose times overlaps in some way with aforementioned event, false otherwise
 */
-(BOOL)overlapWithEKEventForDuration:(NSNumber *)duration andDate:(NSDate *)startOfDate;


@end
