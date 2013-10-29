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
    self.title = @"Event Details";
    _textFieldTitle.text = _task.title;
    NSString *startText = @"From: ";
    startText =[startText stringByAppendingString:[self.formatter stringFromDate:_task.start_time]];
    _textFieldStartTime.text = startText;
    NSString *endText = @"Until: ";
    endText =[endText stringByAppendingString:[self.formatter stringFromDate:_task.end_time]];
    _textFieldEndTime.text = endText;
    _textFieldDuration.text = [_task.duration stringValue];
    _textFieldCategory.text = _task.category;
    _textFieldDescription.text = _task.event_description;
    _textFieldPriority.text = [_task.priority stringValue];
    _textFieldDeadline.text = [self.formatter stringFromDate:_task.deadline];
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
