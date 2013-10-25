//
//  EventDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITAppointmentDetailsViewController.h"
#import "GITAddAppointmentViewController.h"


@implementation GITAppointmentDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void)setAppointment:(Appointment *)appointment
{
    _appointment = appointment;
}

-(void)setUp
{
    self.title = @"Event Details";
    _textFieldTitle.text = _appointment.title;
    NSString *startText = @"From: ";
    startText =[startText stringByAppendingString:[self.formatter stringFromDate:_appointment.start_time]];
    _textFieldStartTime.text = startText;
    NSString *endText = @"Until: ";
    endText =[endText stringByAppendingString:[self.formatter stringFromDate:_appointment.end_time]];
    _textFieldEndTime.text = endText;
    _textFieldDescription.text = _appointment.event_description;
}


-(NSDateFormatter *)formatter
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:kGITDefintionDateFormat];
    }
    return _formatter;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushEditEvent])
    {
        // Get reference to the destination view controller
        GITAddAppointmentViewController *vc = [segue destinationViewController];
        vc.appointment = _appointment;
        vc.appointmentTitle = _appointment.title;
        vc.startTime = _appointment.start_time;
        vc.endTime = _appointment.end_time;
        vc.description = _appointment.event_description;
        vc.editMode = true;
    }
}

@end
