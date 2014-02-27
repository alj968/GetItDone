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

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

-(GITCategory *)addCategoryWithTitle:(NSString *)title error:(NSError **)error
{
    NSDictionary *userInfo;
    GITCategory *newCategory;
    if(!title || title.length == 0)
    {
        userInfo = @{ NSLocalizedDescriptionKey : @"Category must have a title." };
        *error = [[NSError alloc] initWithDomain:kGITErrorUser
                                            code:kGITErrorCodeUser
                                        userInfo:userInfo];
        newCategory = nil;
    }
    else
    {
        //Make sure category of that name doesn't already exist
        BOOL categoryFound = [self.helper checkIfEntityOfType:@"GITCategory" existsWithName:title];
        
        if(categoryFound)
        {
            userInfo = @{ NSLocalizedDescriptionKey : @"Category already exists with that title." };
            *error = [[NSError alloc] initWithDomain:kGITErrorUser
                                                code:kGITErrorCodeUser
                                            userInfo:userInfo];
            newCategory = nil;
        }
        //If it doesn't already exist, send it to db helper to be added
        else
        {
            newCategory = [self.helper makeCategoryWithTitle:title];
            if(!newCategory)
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
    }
    return newCategory;
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

-(BOOL)deleteCategoryForTitle:(NSString *)title withError:(NSError **)error
{
    NSDictionary *userInfo;
    BOOL categoryDeleted;
    //Get all tasks for that category
    NSArray *tasksInCategory = [self.helper fetchTasksInCategory:title];
    //Check if there's a task that did not occur yet associated with this category
    BOOL upcomingTask = NO;
    for(int i = 0; i < tasksInCategory.count; i++)
    {
        GITTask *task = [tasksInCategory objectAtIndex:i];
        if(([task.start_time compare:[NSDate date]] == NSOrderedDescending) || ([task.start_time compare:[NSDate date]] == NSOrderedSame))
        {
            upcomingTask = YES;
        }
    }
    //If upcoming task, don't let you delete
    if(upcomingTask)
    {
        userInfo = @{ NSLocalizedDescriptionKey : @"Cannot delete category with upcoming task." };
        *error = [[NSError alloc] initWithDomain:kGITErrorUser
                                            code:kGITErrorCodeUser
                                        userInfo:userInfo];
        categoryDeleted = NO;
    }
    //Otherwise, send to db to delete
    else
    {
        GITCategory *category = [self.helper fetchCategoryWithTitle:title];
        if(!category)
        {
            userInfo = @{ NSLocalizedDescriptionKey : @"Cannot delete category that doesn't exist." };
            *error = [[NSError alloc] initWithDomain:kGITErrorUser
                                                code:kGITErrorCodeUser
                                            userInfo:userInfo];
            categoryDeleted = NO;
        }
        else
        {
            categoryDeleted = [self.helper deleteCategoryFromDatabase:category];
        }
    }
    return categoryDeleted;
}

@end
