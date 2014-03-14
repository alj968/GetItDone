//
//  GITiCalendarEventManager.m
//  GetItDone
//
//  Created by Amanda Jones on 3/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITEKEventManager.h"

@implementation GITEKEventManager

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

# pragma mark - Deletion methods
-(void)deleteiCalendarEvent:(EKEvent *)ekEvent;
{
    _eventToDelete = ekEvent;
    //Get permission to delete it
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Permission Request"
                                                   message: @"Would you also like to delete this event from its native calendar?"
                                                  delegate: self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [alert show];
    
}

/**
 Handles the alert asking the user's permission to delete the event from the iOS Calendar
 */

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Yes, delete it from native calendar
    if(buttonIndex == 1)
    {
        [self deleteApproved];
    }
}

/**
 Deletes the event with the given identifier from the iOS Calendar
 */
-(void)deleteApproved
{
    BOOL eventDeleted;
    
    //Find event and delete it
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:_eventToDelete.startDate endDate:_eventToDelete.endDate calendars:nil];
    
    NSArray *matchingEvents= [self.eventStore eventsMatchingPredicate:predicate];
    
    NSError *error;
    for(EKEvent * theEvent in matchingEvents)
    {
        if([theEvent.eventIdentifier isEqualToString:_eventToDelete.eventIdentifier])
        {
            eventDeleted = [self.eventStore removeEvent:theEvent span:EKSpanThisEvent commit:YES error:&error];
        }
    }
    
    //Show error message if not deleted
    if(!eventDeleted)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"iOS Calendar Deletion Failed"
                                                       message: @"Could not delete event from the iOS Calendar. Please go to this calendar to delete this event manually."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Fetching methods
//TODO: Change this to only fetch events in the given month or in the given day
-(NSArray *)fetchiCalendarEvents
{
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components - start today
    NSDate *today = [NSDate date];
    
    // Create the end date components - one year from today
    NSDateComponents *sixMonthsFromNowComponents = [[NSDateComponents alloc] init];
    sixMonthsFromNowComponents.month = 6;
    NSDate *sixMonthsFromNow = [calendar dateByAddingComponents:sixMonthsFromNowComponents
                                                         toDate:[NSDate date]
                                                        options:0];
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:today
                                                                      endDate:sixMonthsFromNow
                                                                    calendars:nil];
    // Fetch all events that match the predicate
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

@end
