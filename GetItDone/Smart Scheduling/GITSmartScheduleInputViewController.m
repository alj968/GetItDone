//
//  GITSmartScheduleInputViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITSmartScheduleInputViewController.h"
#import "NSDate+Utilities.h"

@implementation GITSmartScheduleInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Task";
}

//TODO: Implement later when edit is in place
/*
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
 }*/

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

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{    
    [self setLastFieldInfo];
    
    //Get task input
    //Can request a task be smart scheduled as long as all required input is present
    //TODO: Check all fields filled out?
    //TODO: Validate input types
    NSNumber *zeroNumber = [NSNumber numberWithInt:0];
    if (_taskTitle.length > 0 &&![_duration isEqualToNumber:zeroNumber]&& _category.length > 0)
    {
        [self makeTimeSuggestion];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Missing Required Information"
                                                       message: @"Please make sure title, duration and category are filled in."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

-(void)setLastFieldInfo
{
    //Last edited field, e.g one that has not been saved, is
    //going to be one of 6 fields
    if(_lastEditedField == _textFieldTitle)
    {
        _taskTitle = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldDuration)
    {
        _duration = [NSNumber numberWithDouble:[_lastEditedField.text doubleValue]];
    }
    else if(_lastEditedField == _textFieldCategory)
    {
        _category = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldDescription)
    {
        _description = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldPriority)
    {
        _priority = [NSNumber numberWithDouble:[_lastEditedField.text doubleValue]];
    }
    //TODO: Implement later with date picker?
    /*
    else if(_lastEditedField == _textFieldDeadline)
    {
        _deadline = _lastEditedField.text;
    }*/
}
//TODO: Get rid of greater than zero?
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _textFieldTitle && textField.text.length>0)
    {
        _taskTitle = textField.text;
    }
    else if(textField == _textFieldDuration && textField.text.length>0)
    {
        _duration = [NSNumber numberWithDouble:[self.textFieldDuration.text doubleValue]];
    }
    else if(textField == _textFieldCategory && textField.text.length>0)
    {
        _category = self.textFieldCategory.text;
    }
    else if(textField == _textFieldDescription && textField.text.length>0)
    {
        _description = self.textFieldDescription.text;
    }
    else if(textField == _textFieldPriority && textField.text.length>0)
    {
        _priority = [NSNumber numberWithDouble:[self.textFieldPriority.text doubleValue]];
    }
    //TODO: Implement later with date picker?
    /*
     else if(textField == _textFieldDeadline && textField.text.length>0)
     {
     _deadline = self.textFieldDescription.text;
     }*/
}

/*
 Keep track of last edited text field because this one may not have been saved, because textFieldDidEndEditing may have never been called
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _lastEditedField = textField;
    _buttonSubmit.enabled = [self checkForButtonEnbabling:textField];
    
}

//TODO: Work on later for improved way of enbabling done button
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSNumber *zeroNumber = [NSNumber numberWithInt:0];
    if (_textFieldTitle.text.length > 0 &&_textFieldDuration.text.length>0&& _textFieldCategory.text.length > 0)
    {
        _buttonSubmit.enabled = YES;
    }
    else
    {
        _buttonSubmit.enabled = NO;
    }
    //[self validateTextFields];
    return YES;
}
*/

-(BOOL)checkForButtonEnbabling:(UITextField *)textField
{
    BOOL enabled = NO;
    //If title & duration has been filled in and category is being edited
    if(_taskTitle.length > 0 && _duration && textField == _textFieldCategory)
    {
        enabled = YES;
    }
    //If title & category has been filled in and duration is being edited
    if(_taskTitle.length > 0 && _category.length > 0 && textField == _textFieldDuration)
    {
        enabled = YES;
    }
    //If duration & category has been filled in and title is being edited
    if(_duration && _category.length > 0 && textField == _textFieldTitle)
    {
        enabled = YES;
    }
    return enabled;
}

-(void)makeTimeSuggestion
{
    //TODO: Find random date within the week, later gather this time period?
    int dayPeriod = 7;
    _randomDate =[NSDate randomTimeWithinDayPeriod:dayPeriod];
    
    //TODO: Right now assuming event to be scheduled has 1 hour duration, later take this as input
    //Loop until you find a time slot that's not taken
    while([self isTimeSlotTakenWithDuration:_duration andDate:_randomDate]);
    
    NSString *randomDateString = [self.formatter stringFromDate:_randomDate];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Suggested Task Time"
                                                   message: randomDateString
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Accept",@"Reject",nil];
    [alert show];
}

-(BOOL)isTimeSlotTakenWithDuration:(NSNumber *)duration andDate:(NSDate *)date
{
    BOOL found = 0;
    if([self.helper eventWithinDuration:duration startingAt:date])
    {
        found = YES;
    }
    else{
        found = NO;
    }
    return found;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL taskScheduled = NO;
    //Accepted suggsetion
    if (buttonIndex == 1)
    {
        //TODO: Make clear that duration should be in minutes
        //Schedule task
        //TODO: For duration, sending nsnumber to int - make sure this okay
        taskScheduled = [self.helper makeTaskAndSaveWithTitle:_taskTitle startDate:_randomDate description:_description duration:_duration category:_category deadline:_deadline priority:_priority forTask:NULL];
        //Go back to monthly calendar
        if(taskScheduled)
        {
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Save Failed"
                                                           message: @"Could not save task. Please try again."
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
    //Rejected suggestion
    else if(buttonIndex == 2)
    {
        [self makeTimeSuggestion];
    }
}

@end
