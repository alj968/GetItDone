//
//  GITTask.h
//  GetItDone
//
//  Created by Amanda Jones on 3/5/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GITEvent.h"

@class GITCategory;

/**
 The model class for the GITTask entity. It is a child of GITEvent.
 */
@interface GITTask : GITEvent

/**
 The date by which the task must be completed. Optional.
 */
@property (nonatomic, retain) NSDate * deadline;
/**
 How long the task will last. Required.
 */
@property (nonatomic, retain) NSNumber * duration;
/**
 The importance of the event. Required. Low(1) by default. Other options are Medium(2) or High(3)
 */
@property (nonatomic, retain) NSNumber * priority;
/**
 The category the task belongs to. Required. Category "None" by default
 */
@property (nonatomic, retain) GITCategory *belongsTo;

@end
