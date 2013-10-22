//
//  EventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITAddAppointmentViewController.h"
#import "GITCalendarViewController.h"
#import "GITSelectDateViewController.h"
#import "GITDatebaseHelper.h"

@implementation GITAddAppointmentViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Appointment";
}

- (void)viewDidAppear:(BOOL)animated
{
    //If any of the text fields are filled in before going to select date screen,
    //make sure that when you come back to this screen, that prevoiusly selected
    //data will be in the textfields
    //Also ensures that if you're coming in from edit mode, text appears
    if(_appointmentTitle)
    {
        self.textFieldTitle.text = _appointmentTitle;
    }
    if(_startTime)
    {
        self.textFieldStartTime.text = [self.formatter stringFromDate:_startTime];
    }
    if(_endTime)
    {
        self.textFieldEndTime.text = [self.formatter stringFromDate:_endTime];
    }
    if(_description)
    {
        self.textFieldDescription.text = _description;
    }
}

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
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


- (IBAction)addAppointmentButtonPressed:(id)sender
{
    BOOL appointmentAdded = NO;
    [self setLastFieldInfo];
    
    //Set up appointment for entered data
    //Can create an appointment as long as all required input is present
    if (_appointmentTitle && _startTime && _endTime)
    {
        appointmentAdded = [self.helper makeAppointmentAndSaveWithTitle:_appointmentTitle andStartDate:_startTime andEndDate:_endTime andDescription:_description forAppointment:_appointment];
    }
    else
    {
        //TODO: Make into alert
        NSLog(@"Didn't provide all info!");
    }
    if(appointmentAdded)
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
}

-(void)setLastFieldInfo
{
    //Last edited field, e.g one that has not been saved, is
    //either going to be title  or description
    if(_lastEditedField == _textFieldTitle)
    {
        _appointmentTitle = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldDescription)
    {
        _description = _lastEditedField.text;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _textFieldTitle && textField.text.length>0)
    {
        _appointmentTitle = textField.text;
    }
    
    else if(textField == _textFieldDescription && textField.text.length>0)
    {
        _description = self.textFieldDescription.text;
    }
}

/*
 Keep track of last edited text field because this one may not have been saved, because textFieldDidEndEditing may have never been called
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _lastEditedField = textField;
    _buttonDone.enabled = [self checkForButtonEnbabling:textField];

}

-(BOOL)checkForButtonEnbabling:(UITextField *)textField
{
    BOOL enabled = NO;
    //If title has been filled in and date has been chosen
    if(_textFieldTitle.text.length > 0 && _startTime)
    {
        enabled = YES;
    }
    //If title is being filled in and date has been chosen
    else if(_startTime && textField == _textFieldTitle)
    {
        enabled = YES;
    }
    return enabled;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushSelectTime])
    {
        // Get reference to the destination view controller
        GITSelectDateViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.startTime = _startTime;
        vc.endTime = _endTime;
        vc.endTimeChosen = true;
    }
}

#pragma mark - Select Date delegate methods

- (void) selectDateViewController:self finishedWithStartTime:start endTime:end
{
    _startTime = start;
    _endTime = end;
}

@end
