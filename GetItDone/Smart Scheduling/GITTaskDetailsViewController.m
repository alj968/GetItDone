//
//  GITTaskDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/29/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITTaskDetailsViewController.h"

@implementation GITTaskDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setUp];
}

-(void)setTask:(Task *)task
{
    _task = task;
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
    _textViewTitle.text = _task.title;
}

//Set time text view
-(void) setUpTime
{
    NSString *startTimeText = [self.formatter stringFromDate:_task.start_time];
    NSString *endTimeText = [self.formatter stringFromDate:_task.end_time];
    NSString *timeText = [NSString stringWithFormat:@"From: %@ \nUntil: %@",startTimeText,endTimeText];
    _textViewTime.text = timeText;
}

-(void) setUpDetails
{
    //Set the details text view with required fields
    NSString *detailsText = [NSString stringWithFormat:@"Duration: %@ minutes\nCategory: %@",[_task.duration stringValue],_task.category];
    
    //Figure out which optional details are in the db
    NSString *descriptionText;
    if(_task.event_description.length > 0)
    {
        descriptionText = [NSString stringWithFormat:@"\nDescription: %@",_task.event_description];
    }
    NSString *priorityText;
    if(_task.priority)
    {
        priorityText = [NSString stringWithFormat:@"\nPriority: %@", [_task.priority stringValue]];
    }
    NSString *deadlineText;
    if([self.formatter stringFromDate:_task.deadline].length > 0)
    {
        deadlineText = [NSString stringWithFormat:@"\nDeadline: %@",[self.formatter stringFromDate:_task.deadline]];
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

/* IMPLEMENT LATER FOR EDIT
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
*/

@end
