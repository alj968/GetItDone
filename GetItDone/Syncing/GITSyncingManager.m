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

//TODO: Only call this when app is first downloaded & launched
-(void)setUp
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
    {
        if(granted)
        {
            //TODO: Figure out if anything goes here?
        }
        else
        {
            //TODO: Figure out if this is what I want
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not allowing calendar access prevents this app from syncing with your iOS Calendar. If you change your mind, go to Settings - General - Reset - Reset Location & Privacy and then reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        // handle access here
    }];
}

//TODO: Only fetch events upon first downloading app - then just check for changes
-(NSArray *)fetchEvents
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

//TODO: For any modification of ios calendar, must get user permission!
-(BOOL)deleteEventWithIdentifier:(NSString *)identifier
{
    EKEvent *event = [self.eventStore eventWithIdentifier:identifier];
    NSError *error;
    BOOL eventDeleted = [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
    return eventDeleted;
}


@end
