//
//  GITCategoryManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITCategoryManager.h"
#import "GITProjectConstants.h"

@implementation GITCategoryManager

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

-(BOOL)addCategoryWithTitle:(NSString *)title error:(NSError **)error
{
    NSDictionary *userInfo;
    BOOL categoryAdded = FALSE;
    
    //Make sure category of that name doesn't already exist
    BOOL categoryFound = [self.helper checkIfEntityOfType:@"GITCategory" existsWithName:title];
    
    if(categoryFound)
    {
        userInfo = @{ NSLocalizedDescriptionKey : @"Category already exists with that title." };
        *error = [[NSError alloc] initWithDomain:kGITErrorUser
                                            code:kGITErrorCodeUser
                                        userInfo:userInfo];
    }
    //If it doesn't already exist, send it to db helper to be added
    else
    {
        categoryAdded = [self.helper makeCategoryWithTitle:title];
        if(!categoryAdded)
        {
            userInfo = @{ NSLocalizedDescriptionKey : @"Category could not be added. Please try again."};
            *error = [[NSError alloc] initWithDomain:kGITErrorDatabase
                                                code:kGITErrorCodeUser
                                            userInfo:userInfo];
        }
        else
        {
            [self.helper makeTimeSlotTableForCategoryTitle:title];
        }
    }
    return categoryAdded;
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

-(NSArray *)getAllCategoryTitles
{
    NSMutableArray *categoryTitles = [[NSMutableArray alloc] init];
    NSArray *categories = [[NSArray alloc] init];
    categories = [self.helper fetchEntitiesOfType:@"GITCategory"];
    for (NSManagedObject *category in categories)
    {
        NSString *categoryTitle = [category valueForKey:@"title"];
        [categoryTitles addObject:categoryTitle];
    }
    return categoryTitles;
}

@end
