//
//  GITAppointmentManager.m
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITAppointmentManager.h"

@implementation GITAppointmentManager

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

- (BOOL) makeAppointmentAndSaveWithTitle:(NSString *)title
                               startDate:(NSDate *)start
                                 endDate:(NSDate *)end
                             description:(NSString *)description
                          forAppointment:(GITAppointment *)appointment
{
    BOOL appointmentSaved = false;

    //If title null, fill in
    if(!title || title.length == 0)
    {
        title = @"New Appointment";
    }
    //If start >= end
    if([start compare:end] == NSOrderedDescending || [start compare:end] == NSOrderedSame)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Save Failed"
                                                       message: @"Could not save appointment. Start time must be earlier than end time."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        appointmentSaved = [self.helper makeAppointmentAndSaveWithTitle:title startDate:start endDate:end description:description forAppointment:appointment];
    }
    return appointmentSaved;
}

@end
