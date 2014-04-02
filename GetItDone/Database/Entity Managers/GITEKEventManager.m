//
//  GITiCalendarEventManager.m
//  GetItDone
//
//  Created by Amanda Jones on 3/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITEKEventManager.h"
#import "NSDate+Utilities.h"

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
-(NSArray *)fetchiCalendarEventsFrom:(NSDate *)start until:(NSDate *)end
{
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:start
                                                                      endDate:end
                                                                    calendars:nil];
    // Fetch all events that match the predicate
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

-(NSArray *)fetchiCalendarEventsOnDay:(NSDate *)date
{
    NSDate *startDate = [NSDate dateAtBeginningOfDate:date];
    NSDate *endDate = [NSDate dateAtEndOfDate:date];
    return [self fetchiCalendarEventsFrom:startDate until:endDate];
}

//TODO OVERLAP: Return overlapping events here to show user and ask if they'd like to schedule it anyway
-(BOOL)overlapWithEKEventForDuration:(NSNumber *)duration andDate:(NSDate *)startOfDate
{
    BOOL overlap = NO;
    int durationInt = [duration intValue];
    
    //In model, for now assuming duration in terms of minutes
    //dateByAddingTimeInterval is in seconds
    NSDate *endOfDate = [startOfDate dateByAddingTimeInterval:(durationInt*60)];
    
    //Start should be 12:00 am of day week before provided date
    NSDate *predicateStart = [NSDate dateAtBeginningOfDate:[startOfDate dateByAddingTimeInterval:60*60*24*-7]];
    //End should be 12:00 am of one week + one day after the day of the provided date
    NSDate *predicateEnd = [NSDate dateAtEndOfDate:[startOfDate dateByAddingTimeInterval:60*60*24*7]];
    //Create the predicate 
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:predicateStart
                                                                      endDate:predicateEnd
                                                                    calendars:nil];
    // Fetch all events that match the predicate
    NSArray *fetchedObjects = [self.eventStore eventsMatchingPredicate:predicate];
    //Loop through database to check each event
    for(NSManagedObject *info in fetchedObjects)
    {
        NSDate *thisEventStart = [info valueForKey:@"startDate"];
        NSDate *thisEventEnd = [info valueForKey:@"endDate"];
        //Check for any overlap, excluding if one of the events ends when the other starts
        if([startOfDate compare:thisEventEnd] == NSOrderedAscending &&
           [endOfDate compare:thisEventStart] == NSOrderedDescending)
        {
            overlap = YES;
        }
    }
    return overlap;
}

@end
