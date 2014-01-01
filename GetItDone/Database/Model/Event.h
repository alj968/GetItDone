//
//  Event.h
//  GetItDone
//
//  Created by Amanda Jones on 10/22/13.
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
 Time event begins
 */
@property (nonatomic, retain) NSDate * start_time;
/**
 Time event ends
 */
@property (nonatomic, retain) NSDate * end_time;
/**
 Event description (optional)
 */
@property (nonatomic, retain) NSString * event_description;

@end
