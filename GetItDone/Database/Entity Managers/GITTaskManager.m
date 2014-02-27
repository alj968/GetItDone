//
//  GITTaskManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

//TODO: Make title the key (because notification at time of event just knows the title)
//aka make sure two cannot have the same title. Do this for appointment too
#import "GITTaskManager.h"

@implementation GITTaskManager

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

- (GITTask *)makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start description:(NSString *)description duration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task
{
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
    //If no duration, return nil
    if(!duration || !start)
    {
        return nil;
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
    task = [self.helper makeTaskAndSaveWithTitle:title startDate:start endDate:end description:description duration:duration category:category deadline:deadline priority:priority forTask:task];
    
    return task;
}

-(BOOL)isTaskInfoValidForDeadline:(NSDate *)deadline categoryTitle:(NSString *)categoryTitle error:(NSError **)error
{
    BOOL valid = YES;
    //Check deadline
    if(deadline && [deadline compare:[[NSDate date] dateByAddingTimeInterval:60*60]] == NSOrderedAscending)
    {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Deadline must be more than one hour later current time" };
        //Dereference error to change the value of "error"
        *error = [[NSError alloc] initWithDomain:kGITErrorDomainValidation
                                            code:kGITErrorCodeValidation
                                        userInfo:userInfo];
        valid = NO;
    }
    //Check Category
    GITCategory *category = [self.helper fetchCategoryWithTitle:categoryTitle];
    if(!category)
    {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Category has been deleted or altered since chosen. Please re-choose a category." };
        *error = [[NSError alloc] initWithDomain:kGITErrorDomainValidation
                                            code:kGITErrorCodeValidation
                                        userInfo:userInfo];
        valid = NO;
    }
    return valid;
}

- (int)getDayPeriodForTaskPriority:(NSNumber *)priority
{
    if([priority intValue] == 3)
    {
        return 2;
    }
    else if([priority intValue] == 2)
    {
        return 4;
    }
    else
    {
        return 7;
    }
}

@end
