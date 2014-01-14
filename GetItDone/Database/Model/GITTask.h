//
//  GITTask.h
//  GetItDone
//
//  Created by Amanda Jones on 1/8/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GITEvent.h"

@class GITCategory;

@interface GITTask : GITEvent

/**
 The data by which the task must be completed. This information is optional for the user.
 */
@property (nonatomic, retain) NSDate * deadline;
/**
 How long, in minutes, the task will take. This information is required for the user.
 */
@property (nonatomic, retain) NSNumber * duration;
/**
 The numeric importance of the task. Must be between 1 and 3. The user can choose not to provide this information, in which case, the system gives it a default priority of 1 (Low)
 */
@property (nonatomic, retain) NSNumber * priority;
/**
 The category of the task. This information is required for the user.
 */
@property (nonatomic, retain) GITCategory *belongsTo;

@end
