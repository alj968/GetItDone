//
//  Event.h
//  GetItDone
//
//  Created by Amanda Jones on 8/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 Model for the Event entity.
 */
@interface Event : NSManagedObject

/**
 The title of the event
 */
@property (nonatomic, retain) NSString * title;
/**
 The time the event begins
 */
@property (nonatomic, retain) NSDate * start_time;
/**
 The date (including time) the event ends
 */
@property (nonatomic, retain) NSDate * end_time;
/**
 The duration of the event - for now, assuming in terms of hour
 */
@property (nonatomic, retain) NSNumber * duration;
/**
 If the event is a "task" or not, e.g. if it cannot be moved (is a task) or not
 */
@property (nonatomic, retain) NSNumber * task;

@end
