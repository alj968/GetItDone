//
//  Appointment.h
//  GetItDone
//
//  Created by Amanda Jones on 10/22/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"

//TODO: If appointment ends up not having attributes other than the ones in event, can delete this entity. Decide on!
/**
 Model for the Appointment entity, which is a subentity of Event.
 */
@interface Appointment : Event

@end
