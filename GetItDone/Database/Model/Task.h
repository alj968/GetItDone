//
//  Task.h
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"

/**
 Model for the Task entity, which is a subentity of Event.
 */
@interface Task : Event

/**
Category of task. Required. User can choose from a list of categories, which they can edit. User can also choose the category of "no category."
 */
@property (nonatomic, retain) NSString * category;
/**
 The date before which the task must be completed.
 */
@property (nonatomic, retain) NSDate * deadline;
/**
 The numeric priority of the task. Can be low (1), medium (2), or high (3).
 */
@property (nonatomic, retain) NSNumber * priority;
/**
 How long, in minutes, the task is expected to take.
 */
@property (nonatomic, retain) NSNumber * duration;

@end
