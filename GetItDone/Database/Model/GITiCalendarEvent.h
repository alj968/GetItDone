//
//  GITiCalendarEvent.h
//  GetItDone
//
//  Created by Amanda Jones on 3/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//TODO - delete this entity and this class!
/**
 The model class for the GITiCalendarEvent entity. This is the entity for all events from the iOS Calendar.
 */
@interface GITiCalendarEvent : GITEvent

/**
 The event's unique identifier, taken from the iOS Calendar
 */
@property (nonatomic, retain) NSString * identifier;

@end
