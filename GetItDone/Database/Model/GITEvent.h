//
//  GITEvent.h
//  GetItDone
//
//  Created by Amanda Jones on 3/5/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 The model class for the GITEvent entity. GITEvent is the parent of GITTask and GITAppointment. Imported events will get saved as GITEvents.
 */
@interface GITEvent : NSManagedObject

/**
 End time of event. Required.
 */
@property (nonatomic, retain) NSDate * end_time;
/**
 Description of the event. Optional. For an imported event, this will give the event identifier from its native calendar.
 */
@property (nonatomic, retain) NSString * event_description;
/**
 Start time of event. Required.
 */
@property (nonatomic, retain) NSDate * start_time;
/**
 Title of the event. Required.
 */
@property (nonatomic, retain) NSString * title;

@end
