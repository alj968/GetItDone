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


@interface Task : Event

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * deadline;
@property (nonatomic, retain) NSNumber * priority;
//Duration assumed to be in minutes
@property (nonatomic, retain) NSNumber * duration;

@end
