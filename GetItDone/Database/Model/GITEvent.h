//
//  Event.h
//  GetItDone
//
//  Created by Amanda Jones on 1/6/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GITEvent : NSManagedObject

/**
 The title of the event. This information is required.
 */
@property (nonatomic, retain) NSString * title;
/**
 The time the event begins. This information is required.
 */
@property (nonatomic, retain) NSDate * start_time;
/**
 The time the event ends. This information is required.
 */
@property (nonatomic, retain) NSDate * end_time;
/**
 The description of the event. This information is optinal.
 */
@property (nonatomic, retain) NSString * event_description;


@end
