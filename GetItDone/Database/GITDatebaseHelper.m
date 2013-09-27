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

- (void) makeEventAndSaveWithTitle:(NSString *)title
                      andStartDate:(NSDate *)start
                        andEndDate:(NSDate *)end
                       andTaskBool:(NSString *)taskBool
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
    [event setTask:[self taskStringToNumber:taskBool]];
    [event setDuration:[self durationStringToNumber:duration]];
}

- (BOOL) saveEventSuccessful
{
    BOOL success = YES;
    //Save event
    [(GITAppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    //Log error in saving data
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

- (void) printDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Title: %@", [info valueForKey:@"title"]);
        NSLog(@"Start time: %@", [info valueForKey:@"start_time"]);
        NSLog(@"End time: %@", [info valueForKey:@"end_time"]);
        NSLog(@"Duration: %@", [info valueForKey:@"duration"]);
        NSLog(@"Task: %@", [info valueForKey:@"task"]);
    }
}

- (NSNumber *)durationStringToNumber:(NSString *)durationString
{
    return [NSNumber numberWithDouble:[durationString doubleValue]];
}


- (NSNumber *)taskStringToNumber:(NSString *)taskString
{
    BOOL taskBoolean = [taskString isEqualToString:@"YES"];
    return [NSNumber numberWithBool:taskBoolean];
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
