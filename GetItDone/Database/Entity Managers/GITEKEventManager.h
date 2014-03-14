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
 Fetches all events from the iCal
 @return Returns all EKEvents within 6 months
 */
-(NSArray *)fetchiCalendarEvents;

@end
