//
//  GITAppointmentManager.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITDatebaseHelper.h"

/**
 This is the entity manager for Appointment. It is responsible for all business logic for appointment, and communicates with the database helper so the database helper can perform the requested CRUD operations.
 */
@interface GITAppointmentManager : NSObject

/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;
/**
 Fills in any missing required attributes, and does validation. Makes sure there's a title, and start date is earlier than end date. If the information is valid, sends the information to the database helper so it can add the appointment to the database.
 @param title Title of event
 @param start State date of event
 @param end End date of event
 @param description Description of event
 @param appointment If you are modifying an existing apointment, that appointment is passed in
 @return Returns true if database helper saved event successfully, false otherwise
 */
- (BOOL) makeAppointmentAndSaveWithTitle:(NSString *)title
                               startDate:(NSDate *)start
                                 endDate:(NSDate *)end
                             description:(NSString *)description
                          forAppointment:(GITAppointment *)appointment;

@end
