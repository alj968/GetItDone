//
//  Task.h
//  GetItDone
//
//  Created by Amanda Jones on 10/22/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"


@interface Task : Event

@property (nonatomic, retain) NSNumber * duration;

@end
