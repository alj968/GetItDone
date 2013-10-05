//
//  GITDatebaseHelper.m
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITDatebaseHelper.h"

@implementation GITDatebaseHelper

-(NSManagedObjectContext *)context
{
    if(!_context)
    {
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    }
    return _context;
}

- (BOOL) makeEventAndSaveWithTitle:(NSString *)title
                      andStartDate:(NSDate *)start
                        andEndDate:(NSDate *)end
                       andTaskBOOL:(NSString *)taskBOOL
                       andDuration:(NSString *)duration
                          forEvent:(Event *)event
{
    if(!event)
    {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.context];
    }
    [event setTitle:title];
    [event setStart_time:start];
    [event setEnd_time:end];
    [event setTask:[self taskStringToNumber:taskBOOL]];
    [event setDuration:[self durationStringToNumber:duration]];
    
    return [self saveEventSuccessful];
}

- (BOOL) saveEventSuccessful
{
    BOOL success = YES;

    [(GITAppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        success = NO;
    }
    else
    {
        [self printDatabase];
    }
    return success;
}

-(NSArray *) fetchEventsOnDay:(NSDate *)day
{
    //Form fetch request for event entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    //Times square shows dateSelected as having time 4:00 am, must subtract 4 hours
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:@"gregorian"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:-4];
    day = [cal dateByAddingComponents:comps toDate:day  options:0];
    
    //End of date range will be 12:00 am of next day
    NSDate *endOfDateSelected = [day dateByAddingTimeInterval:(24*60*60)];
    
    //Form predicate to only get events in the specified date range
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"start_time <= %@ && start_time >= %@", endOfDateSelected, day];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"start_time" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

-(NSArray *) fetchWholeDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (void) printDatabase
{
    NSArray *fetchedObjects = [self fetchWholeDatabase];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Title: %@", [info valueForKey:@"title"]);
        NSLog(@"Start time: %@", [info valueForKey:@"start_time"]);
        NSLog(@"End time: %@", [info valueForKey:@"end_time"]);
        NSLog(@"Duration: %@", [info valueForKey:@"duration"]);
        NSLog(@"Task: %@", [info valueForKey:@"task"]);
    }
}

 //IN PROGRESS - IGNORE FOR NOW
- (BOOL)eventWithinDuration:(int)duration startingAt:(NSDate *)startTime
{
    BOOL hasEvent = NO;
    //In model, for now assuming duration in terms of hour
    NSDate *endTime = [startTime dateByAddingTimeInterval:(duration*60*60)];
    NSArray *fetchedObjects = [self fetchWholeDatabase];
    for(NSManagedObject *info in fetchedObjects)
    {
        NSDate *eventStartTime = [info valueForKey:@"start_time"];
        NSDate *eventEndtime = [info valueForKey:@"end_time"];
        if((eventStartTime >= startTime && eventStartTime<= endTime)
         || (eventEndtime >= startTime && eventEndtime <= endTime)
         || (eventStartTime <= startTime && eventEndtime >= endTime))
        if(eventStartTime >= startTime && eventStartTime<= endTime)
        {
            hasEvent = YES;
        }
        else if(eventEndtime >= startTime && eventEndtime <= endTime)
        {
            hasEvent = YES;
        }
        else if(eventStartTime <= startTime && eventEndtime >= endTime)
        {
            hasEvent = YES;
        }
        
    }
    return hasEvent;
}

- (NSNumber *)durationStringToNumber:(NSString *)durationString
{
    return [NSNumber numberWithDouble:[durationString doubleValue]];
}

- (NSNumber *)taskStringToNumber:(NSString *)taskString
{
    BOOL taskboolean = [taskString isEqualToString:@"YES"];
    return [NSNumber numberWithBool:taskboolean];
}

-(NSString *)taskNumberToString:(NSNumber *)taskNumber
{
    if([taskNumber isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        return @"YES";
    }
    else
    {
        return @"NO";
    }
}

@end
