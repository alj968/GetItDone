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

@interface GITTask : GITEvent

@property (nonatomic, retain) NSDate * deadline;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) GITCategory *belongsTo;

@end
