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
    //TODO: Make sure this now done in add task vc (should be) and if it works, remove this
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

- (BOOL)isTaskInfoValidForDuration:(NSNumber *)duration deadline:(NSDate *)deadline error:(NSError **)error
{
    /*
     Check duration. Must be positive integer.
     */
    NSNumber *zeroNumber = [NSNumber numberWithInt:0];
    if([duration isEqualToNumber:zeroNumber] || ([duration compare:zeroNumber] == NSOrderedAscending))
    {
        /**
         SELFNOTE: Should always have a value for the key NSLocalizedDescriptionKey, otherwise a default string is constructed from the domain and the code. Can get this text by doing error.localizedDescription
         */
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Duration must be greater than 0." };
        //Dereference error to change the value of "error"
        *error = [[NSError alloc] initWithDomain:kGITErrorDomainValidation
                                            code:kGITErrorCodeValidation
                                        userInfo:userInfo];
        return NO;
    }
    
    /*
     Check deadline. It cannot be earlier than, or same as, the current time
     */
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

@end
