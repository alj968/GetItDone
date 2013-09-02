//
//  Event.h
//  GetItDone
//
//  Created by Amanda Jones on 8/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 The database model for the Event entity.
 */
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

/**
 The duration of the event
 */
@property (nonatomic, retain) NSNumber * duration;
/**
 The time the event ends
 */
@property (nonatomic, retain) NSDate * end_time;
/**
 The time the event begins
 */
@property (nonatomic, retain) NSDate * start_time;
/**
 If the event is a "task" or not, e.g. if it cannot be moved (is a task) or not
 */
@property (nonatomic, retain) NSNumber * task;
/**
 The title of the event
 */
@property (nonatomic, retain) NSString * title;

@end
