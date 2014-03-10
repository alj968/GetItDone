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
    self.title = @"Details";
}

/**
 Sets up the event information to display.
 */
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

/**
 Sets the title text view
 */
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

/**
 Sets the time text vew
 */
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

/**
 Sets the event details text view with all additional information known about the event
 */
-(void) setUpDetails
{
    NSString *detailsText = @"";
    NSString *descriptionText;
    NSString *priorityText;
    NSString *deadlineText;
    
    if(_task)
    {
        //Set the details text view with required fields
        detailsText = [NSString stringWithFormat:@"Duration: %@ minutes\nCategory: %@",[_task.duration stringValue],(_task.belongsTo).title];
        
        //Figure out which optional details are in the db
        if(_task.event_description.length > 0)
        {
            descriptionText = [NSString stringWithFormat:@"\nDescription: %@",_task.event_description];
        }
        if(_task.priority)
        {
            NSString *priorityString;
            if(_task.priority  == [NSNumber numberWithInt:1])
            {
                priorityString = @"None/Low";
            }
            else if(_task.priority  == [NSNumber numberWithInt:2])
            {
                priorityString = @"Medium";
            }
            else if(_task.priority  == [NSNumber numberWithInt:3])
            {
                priorityString = @"High";
            }
            priorityText = [NSString stringWithFormat:@"\nPriority: %@", priorityString];
            
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
    NSDate *startDate;
    if(_task)
    {
        startDate = _task.start_time;
    }
    else if(_appointment)
    {
        startDate = _appointment.start_time;
    }
    //If event is passed, don't let it be edited
    if([startDate compare:[NSDate date]] == NSOrderedAscending)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Cannot edit event that has already begun or is over" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if(_appointment)
        {
            [self performSegueWithIdentifier:kGITSeguePushEditAppointment sender:nil];
        }
        else if(_task)
        {
            [self performSegueWithIdentifier:kGITSeguePushEditTask sender:nil];
        }
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
        vc.startTime = _appointment.start_time;
        vc.endTime = _appointment.end_time;
        vc.editMode = true;
    }
    //If it's a task
    else if([[segue identifier] isEqualToString:kGITSeguePushEditTask])
    {
        GITAddTaskViewController *vc = [segue destinationViewController];
        vc.task = _task;
        vc.editMode = true;
    }
}

@end
