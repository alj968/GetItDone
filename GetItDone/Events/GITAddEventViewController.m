//
//  EventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITAddEventViewController.h"
#import "Event.h"
#import "GITCalendarViewController.h"
#import "GITSelectDateViewController.h"
#import "GITDatebaseHelper.h"

@implementation GITAddEventViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add/Edit Event";
}

- (void)viewDidAppear:(BOOL)animated
{
    //If any of the text fields are filled in before going to select date screen,
    //make sure that when you come back to this screen, that prevoiusly selected
    //data will be in the textfields
    //Also ensures that if you're coming in from edit mode, text appears
    if(_eventTitle)
    {
        self.textFieldTitle.text = _eventTitle;
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


- (IBAction)addEventButtonPressed:(id)sender
{
    BOOL eventAdded = NO;
    [self setLastFieldInfo];
    
    //Set up event for entered data
    //Can create an event as long as all required input is present
    //TODO: Validate input
    if (_eventTitle && _startTime && _endTime)
    {
        /*
        if(_description.length <= 0) {
         _description = @"No description";
        }
         */
        eventAdded = [self.helper makeAppointmentAndSaveWithTitle:_eventTitle andStartDate:_startTime andEndDate:_endTime andDescription:_description forEvent:_event];
    }
    else
    {
        //TODO: Make into alert
        NSLog(@"Didn't provide all info!");
    }
    if(eventAdded)
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
}

-(void)setLastFieldInfo
{
    //Last edited field, e.g one that has not been saved, is
    //either going to be title, duration or task
    if(_lastEditedField == _textFieldTitle)
    {
        _eventTitle = _lastEditedField.text;
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
        _eventTitle = textField.text;
    }
    
    else if(textField == _textFieldDescription && textField.text.length>0)
    {
        _description = self.textFieldDescription.text;
    }
}

//Keep track of last edited text field because this one may not have
//been saved, because textFieldDidEndEditing may have never been called
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _lastEditedField = textField;
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
