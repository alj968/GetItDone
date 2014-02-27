//
//  GITSetUpDatabase.h
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITCategoryManager.h"

@interface GITSetUpDatabase : NSObject

@property (nonatomic, strong) GITCategoryManager *categoryManager;

/**
 Sets up database with default category and a time slot table for it
 */
-(void)setUp;

@end
