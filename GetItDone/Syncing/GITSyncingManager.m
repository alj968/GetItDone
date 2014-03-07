//
//  GITSyncWithiCal.m
//  GetItDone
//
//  Created by Amanda Jones on 3/3/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITSyncingManager.h"

@implementation GITSyncingManager


- (EKEventStore *)eventStore
{
    if(!_eventStore)
    {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

-(void)setUpiCal
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if(granted)
         {
             NSArray *events = [self fetchiCalEvents];
             //TODO: ISSUE - this still doesn't happen before the calendar view is displayed - loading screen? herm?
             [self.helper addSyncedEventsToCalendar:events];
             
             //Register for notification of changes
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:self.eventStore];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not allowing calendar access prevents this app from syncing with your iOS Calendar. If you change your mind, go to Settings - General - Reset - Reset Location & Privacy and then reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
    
}

/**
 Handes when iCal events changed
 */
- (void)storeChanged:(NSNotification *)notification
{
    //TODO: Delete all events and reload them? - ask herm
    //[self fetchiCalEvents];
}


//TODO: Bug - if I try to touch a day of the week while these evenst are still being added to the db, whole app freezes and I need to rebuild it. herm?
-(NSArray *)fetchiCalEvents
{
    //TODO: First make sure you have access to calendar? Some kind of bool set in setUp?
    //Assuming we have access:
    
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components - start today
    NSDate *today = [NSDate date];
    
    // Create the end date components - one year from today
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:today
                                                                      endDate:oneYearFromNow
                                                                    calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

-(BOOL)deleteiCalEventWithIdentifier:(NSString *)identifier andStartTime:(NSDate *)start andEndTime:(NSDate *)end;
{
    BOOL eventDeleted;
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:start endDate:end calendars:nil];
    
     NSArray *matchingEvents= [self.eventStore eventsMatchingPredicate:predicate];
     NSString *recurrenceEventIdentifier = identifier;
    
    NSError *error;
     for(EKEvent * theEvent in matchingEvents)
     {
         if([theEvent.eventIdentifier isEqualToString:recurrenceEventIdentifier])
         {
             eventDeleted = [self.eventStore removeEvent:theEvent span:EKSpanThisEvent commit:YES error:&error];
         }
     }
    return eventDeleted;
}


@end
