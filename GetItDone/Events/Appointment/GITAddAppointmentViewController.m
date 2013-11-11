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
    //Check for button enabling - importantt when coming back from selecting a time
    _buttonDone.enabled = [self enableDoneButton];
    
    /*
      If any text fields filled in before select date screen,
      fill these fields in upon coming back to this screen
      Also ensures that if you're coming in from edit mode, text appears
     */
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
    
    /*
     For this button to be enbaled, we know all reuqired fields filled in
     Start and end date assigned upon leaving select date screen
     */
    _appointmentTitle = _textFieldTitle.text;
    _description = _textFieldDescription.text;
    
    appointmentAdded = [self.helper makeAppointmentAndSaveWithTitle:_appointmentTitle startDate:_startTime endDate:_endTime description:_description forAppointment:_appointment];
    
    if(appointmentAdded)
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Save Failed"
                                                       message: @"Could not save appointment. Please try again."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     This method gets called before the text field has a length (ie before character is actually
     entered). So, when the location is 0, need to check if button should be enabled or not, to
     ensure that upon entering first character, it's enabled, and upon deleting first character
     (when it is the only character), it's disabled
     */
    if(range.location == 0)
    {
        if((string.length > 0 || _textFieldTitle.text.length > 1) && _startTime && _endTime > 0)
        {
            _buttonDone.enabled = YES;
        }
        else
        {
            _buttonDone.enabled = NO;
        }
    }
    //Otherwise, do normal check
    else
    {
        _buttonDone.enabled = [self enableDoneButton];
    }
    return true;
}

//If all required text fields filled in, done button should be enabled
-(BOOL)enableDoneButton
{
    BOOL enabled;
    if(_textFieldTitle.text.length > 0 && _startTime && _endTime)
    {
        enabled = YES;
    }
    else
    {
        enabled = NO;
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
        if(_editMode)
        {
            vc.endTimeChosen = true;
        }
    }
}

#pragma mark - Select Date delegate methods

- (void) selectDateViewController:self finishedWithStartTime:start endTime:end
{
    _startTime = start;
    _endTime = end;
}

@end
