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
#import "GITSelectDate.h"
#import "GITDatebaseHelper.h"

@implementation GITAddEventViewController

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
        [_formatter setDateFormat:@"MMM d, y h:mm a"];
    }
    return _formatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    if(_duration)
    {
        self.textFieldDuration.text = _duration;
    }
    if(_task)
    {
        self.textFieldTask.text = _task;
    }
}

- (IBAction)addEventButton:(id)sender
{
    [self setEventInfo];
    
    if([self.helper saveEventSuccessful])
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
}

-(void)setEventInfo
{
    //Last edited field, e.g one that has not been saved, is
    //either going to be title, duration or task
    if(_lastEditedField == _textFieldTitle)
    {
        _eventTitle = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldDuration)
    {
        _duration = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldTask)
    {
        _task = _lastEditedField.text;
    }
    
    //Set up event for entered data
    //TODO: Validate input
    if (_eventTitle && _startTime && _endTime && _duration && _task)
    {
        [self.helper makeEventAndSaveWithTitle:_eventTitle andStartDate:_startTime andEndDate:_endTime andTaskBool:_task andDuration:_duration forEvent:_event];
    }
    else{
        //TODO: Make into alert
        NSLog(@"Didn't provide all info!");
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _textFieldTitle)
    {
        _eventTitle = textField.text;
    }
    else if(textField == _textFieldDuration && textField.text.length>0)
    {
        _duration = self.textFieldDuration.text;
    }
    else if(textField == _textFieldTask && textField.text.length>0)
    {
        _task = self.textFieldTask.text;
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
    if ([[segue identifier] isEqualToString:@"toSelectTime"])
    {
        // Get reference to the destination view controller
        GITSelectDate *vc = [segue destinationViewController];
        vc.addVC = self;
        vc.startTime = _startTime;
        vc.endTime = _endTime;
    }
}

@end
