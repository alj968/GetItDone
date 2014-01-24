//
//  GITSetUpDatabase.m
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITSetUpDatabase.h"
#import "GITCategory.h"

@implementation GITSetUpDatabase

- (GITCategoryManager *)categoryManager
{
    if(!_categoryManager)
    {
        _categoryManager = [[GITCategoryManager alloc] init];
    }
    return _categoryManager;
}

-(void)setUp
{
    //Add default categories, and the cateogry manager will add their time slot tables
    //TODO: Decide on what default categories should be and make them - keep 'none' becuase it's selected when add task view controller initialized
    [self.categoryManager addCategoryWithTitle:@"None"];
}

@end
