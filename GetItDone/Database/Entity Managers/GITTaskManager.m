//
//  GITTaskManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITTaskManager.h"

@implementation GITTaskManager

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

- (BOOL)makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start description:(NSString *)description duration:(NSNumber *)duration category:(NSString *)category deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task
{
    BOOL taskSaved;
    
    //Makes sure there's a title
    if(title.length == 0)
    {
        title = @"New Task";
    }
    
    //If no priority, give a low priority value (1)
    if([priority stringValue].length == 0)
    {
        priority = [NSNumber numberWithInt:1];
    }
    
    /*
     Calculate end time
     (Duration in terms of minutes but adds time intervals in seconds)
     */
    int durationInt = [duration intValue];
    NSDate *end = [start dateByAddingTimeInterval:(durationInt * 60)];
    
    //Save task to database using database helper
    taskSaved = [self.helper makeTaskAndSaveWithTitle:title startDate:start endDate:end description:description duration:duration category:category deadline:deadline priority:priority forTask:task];
    
    return taskSaved;
}

-(NSString *)validateTaskInfoForDuration:(NSNumber *)duration deadline:(NSDate *)deadline
{
    NSString *errorMessage;
    
    /*
     Check duration. Must be positive integer.
     */
    NSNumber *zeroNumber = [NSNumber numberWithInt:0];
    if([duration isEqualToNumber:zeroNumber] || ([duration compare:zeroNumber] == NSOrderedAscending))
    {
        errorMessage = @"Duration must be greater than 0.";
    }
    
    /*
     Check deadline. It cannot be earlier than, or same as, the current time
     */
    if(deadline && ([deadline compare:[[NSDate date] dateByAddingTimeInterval:60]] == NSOrderedAscending))
    {
        errorMessage = @"Deadline must be later date than current time.";
    }
    return errorMessage;
}

@end
