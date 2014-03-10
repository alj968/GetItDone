//
//  GITSyncWithiCal.h
//  GetItDone
//
//  Created by Amanda Jones on 3/3/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

/**
 This class handles the syncing with external calendars, such as iCal.
 */
@interface GITSyncingManager : NSObject

/**
 The iCal's event store
 */
@property (nonatomic, strong) EKEventStore *eventStore;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 Asks the user to access their iCal event and handles their answer
 */
-(void)setUpiCal;
/**
 Fetches all events from the iCal
 @return Returns all events found from today until next year
 */
-(NSArray *)fetchiCalEvents;
/**
 Deletes the event with the given identifier from the iCal
 This method only gets called if the user gave permission to modify the iCal event
 @param identifier The event identifier from the event's native calendar
 @param start The start time of the event to be deleted
 @param end The end time of the event to be deleted
 @return Returns true if successfully deleted, false otherwise
 */
-(BOOL)deleteiCalEventWithIdentifier:(NSString *)identifier andStartTime:(NSDate *)start andEndTime:(NSDate *)end;
/**
 Finds the EKEvent with the identifier contained in the description of the GITEvent provided
 @param event The GITEvent selected 
 @return The matching EKEvent
 */
-(EKEvent *)fetchEKEventFromEvent:(GITEvent *)event;


@end
