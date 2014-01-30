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

- (BOOL)makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start description:(NSString *)description duration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task
{
    BOOL taskSaved;
    
    //Makes sure there's a title
    if(!title || title.length == 0)
    {
        title = @"New Task";
    }
    
    //If no priority, give a low priority value (1)
    if(!priority || [priority stringValue].length == 0)
    {
        priority = [NSNumber numberWithInt:1];
    }
    //If no category, give it default category of "None"
    if(!categoryTitle)
    {
        categoryTitle = @"None";
    }
    
    /*
     Calculate end time
     (Duration in terms of minutes but adds time intervals in seconds)
     */
    int durationInt = [duration intValue];
    NSDate *end = [start dateByAddingTimeInterval:(durationInt * 60)];
    
    /*
     Get category from title
     */
    GITCategory *category = [self.helper fetchCategoryWithTitle:categoryTitle];
    
    //Save task to database using database helper
    taskSaved = [self.helper makeTaskAndSaveWithTitle:title startDate:start endDate:end description:description duration:duration category:category deadline:deadline priority:priority forTask:task];
    
    return taskSaved;
}

- (BOOL)isTaskInfoValidForDeadline:(NSDate *)deadline error:(NSError **)error
{
    if(deadline && ([deadline compare:[[NSDate date] dateByAddingTimeInterval:60]] == NSOrderedAscending))
    {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Deadline must be later date than current time." };
        //Dereference error to change the value of "error"
        *error = [[NSError alloc] initWithDomain:kGITErrorDomainValidation
                                            code:kGITErrorCodeValidation
                                        userInfo:userInfo];
        return NO;
    }
    return YES;
}

- (int)getDayPeriodForTaskPriority:(NSNumber *)priority
{
    if([priority intValue] == 1)
    {
        return 7;
    }
    else if([priority intValue] == 2)
    {
        return 4;
    }
    else
    {
        return 2;
    }
}

@end
