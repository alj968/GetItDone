//
//  GITCategoryManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITCategoryManager.h"

@implementation GITCategoryManager

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

-(BOOL)addCategoryWithTitle:(NSString *)title
{
    BOOL categoryAdded = FALSE;
    //Make sure category of that name doesn't already exist
    BOOL categoryFound = [self.helper checkIfEntityOfType:@"GITCategory" existsWithName:title];
    //If it doesn't already exist, send it to db helper to be added
    if(!categoryFound)
    {
        categoryAdded = [self.helper makeCategoryWithTitle:title];
    }
    if(categoryAdded)
    {
        [self.helper makeTimeSlotTableForCategoryTitle:title];
    }
    return categoryAdded;
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
