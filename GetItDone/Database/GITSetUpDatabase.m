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
//TODO - Have something call this
-(void)setUp
{
    //Add default category "None", and the cateogry manager will add the time slot table
    NSError *error;
    [self.categoryManager addCategoryWithTitle:@"None" error:&error];
}

@end
