//
//  GITTaskDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/29/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITEventDetailsViewController.h"
#import "GITAddAppointmentViewController.h"
#import "GITAddTaskViewController.h"

@implementation GITEventDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setUp];
}

-(void)setTask:(Task *)task
{
    _task = task;
}

-(void)setAppointment:(Appointment *)appointment
{
    _appointment = appointment;
}

-(void)setUp
{
    [self setUpTitle];
    [self setUpTime];
    [self setUpDetails];
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

//Set title text view
-(void) setUpTitle
{
    self.title = @"Event Details";
    if(_task)
    {
        _textViewTitle.text = _task.title;
    }
    else if(_appointment)
    {
        _textViewTitle.text = _appointment.title;
    }
}

//Set time text view
//HERM: Should I move these to header so I can comment then?
-(void) setUpTime
{
    NSString *startTimeText;
    NSString *endTimeText;
    
    if(_task)
    {
        startTimeText = [self.formatter stringFromDate:_task.start_time];
        endTimeText = [self.formatter stringFromDate:_task.end_time];
    }
    else if(_appointment)
    {
        startTimeText = [self.formatter stringFromDate:_appointment.start_time];
        endTimeText = [self.formatter stringFromDate:_appointment.end_time];
    }
    NSString *timeText = [NSString stringWithFormat:@"From: %@ \nUntil: %@",startTimeText,endTimeText];
    _textViewTime.text = timeText;
}

-(void) setUpDetails
{
    NSString *detailsText;
    NSString *descriptionText;
    NSString *priorityText;
    NSString *deadlineText;
    
    if(_task)
    {
        //Set the details text view with required fields
        detailsText = [NSString stringWithFormat:@"Duration: %@ minutes\nCategory: %@",[_task.duration stringValue],_task.category];
        
        //Figure out which optional details are in the db
        if(_task.event_description.length > 0)
        {
            descriptionText = [NSString stringWithFormat:@"\nDescription: %@",_task.event_description];
        }
        if(_task.priority)
        {
            priorityText = [NSString stringWithFormat:@"\nPriority: %@", [_task.priority stringValue]];
        }
        if([self.formatter stringFromDate:_task.deadline].length > 0)
        {
            deadlineText = [NSString stringWithFormat:@"\nDeadline: %@",[self.formatter stringFromDate:_task.deadline]];
        }
    }
    else if(_appointment)
    {
        //Figure out which optional details are in the db
        if(_task.event_description.length > 0)
        {
            descriptionText = [NSString stringWithFormat:@"\nDescription: %@",_task.event_description];
        }
    }
    
    //Add supplied optional attirbutes to details text view
    if(descriptionText)
    {
        detailsText = [detailsText stringByAppendingString:descriptionText];
    }
    if(priorityText)
    {
        detailsText = [detailsText stringByAppendingString:priorityText];
    }
    if(deadlineText)
    {
        detailsText = [detailsText stringByAppendingString:deadlineText];
    }
    _textViewDetails.text = detailsText;
}

- (IBAction)buttonEditEvent:(id)sender {
    if(_appointment)
    {
        [self performSegueWithIdentifier:kGITSeguePushEditAppointment sender:nil];
    }
    else if(_task)
    {
        [self performSegueWithIdentifier:kGITSeguePushEditTask sender:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If it's an appointment
    if ([[segue identifier] isEqualToString:kGITSeguePushEditAppointment])
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
    //Else
    else if([[segue identifier] isEqualToString:kGITSeguePushEditTask])
    {
        GITAddTaskViewController *vc = [segue destinationViewController];
        vc.task = _task;
        vc.taskTitle = _task.title;
        vc.duration = _task.duration;
        vc.category = _task.category;
        vc.description = _task.event_description;
        vc.priority = _task.priority;
        vc.deadline = _task.deadline;
        vc.editMode = true;
    }
}

@end
