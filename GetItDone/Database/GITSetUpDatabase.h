//
//  GITSetUpDatabase.h
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITCategoryManager.h"

//TODO: Later talk to herm about better way to do this
@interface GITSetUpDatabase : NSObject

@property (nonatomic, strong) GITCategoryManager *categoryManager;

/**
 Sets up database with default categories and a time slot table for each one
 */
-(void)setUp;

@end
