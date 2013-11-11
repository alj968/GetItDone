//
//  GITSmartScheduleInputViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITAddTaskViewController.h"
#import "NSDate+Utilities.h"

@implementation GITAddTaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Task";
}

- (void)viewDidAppear:(BOOL)animated
{
    //If any of the text fields are filled in before going to select date screen,
    //make sure that when you come back to this screen, that prevoiusly selected
    //data will be in the textfields
    //Also ensures that if you're coming in from edit mode, text appears
    if(_taskTitle)
    {
        self.textFieldTitle.text = _taskTitle;
    }
    
    if(_duration)
    {
        self.textFieldDuration.text = [_duration stringValue];
    }
    if(_category)
    {
        self.textFieldCategory.text = _category;
    }
    if(_description)
    {
        self.textFieldDescription.text = _description;
    }
    if(_priority)
    {
        self.textFieldPriority.text = [_priority stringValue];
    }
    if(_deadline)
    {
        self.textFieldDeadline.text = [self.formatter stringFromDate:_deadline];
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

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{
    //Set properties with text field text
    _taskTitle = _textFieldTitle.text;
    _duration = [NSNumber numberWithDouble:[_textFieldDuration.text doubleValue]];
    _category = _textFieldCategory.text;
    _description = _textFieldDescription.text;
    _priority =  [NSNumber numberWithDouble:[_textFieldPriority.text doubleValue]];
    //(Deadline assigned when date picker has a date picked)
    
    if(!_editMode) {
        //Get task input
        //Can request a task be smart scheduled as long as all required input is present
        NSNumber *zeroNumber = [NSNumber numberWithInt:0];
        /*
         Make sure priority and duration are numbers
         Only care that priority is not zero if it's filled in
         */
        if([_duration isEqualToNumber:zeroNumber] || ([_priority isEqualToNumber:zeroNumber] && _textFieldPriority.text.length > 0))
        {
            [self showAlertWithTitle:@"Incorrect input" andMessage:@"Please make sure duration and priority (if entered) is a number."];
        }
        //Double check to make sure this is there (even though button should be disabled if it's not)
        else if (_taskTitle.length <= 0 || _category.length <= 0)
        {
            [self showAlertWithTitle:@"Missing Required Information" andMessage:@"Please make sure title, duration and category are filled in. Please ensure duration is a number."];
        }
        else
        {
            [self makeTimeSuggestion];
        }
    }
    //TODO: Implement what to do when a task gets edited here
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: title
                                                   message: message
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}

-(void)makeTimeSuggestion
{
    //At least for now, always scheduling a task within the week (unless priority shortens that time period)
    int dayPeriod = 7;
    _randomDate =[NSDate randomTimeWithinDayPeriod:dayPeriod];
    
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
        //Schedule task
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

//Required: title, duration, category
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     This method gets called before the text field has a length (ie before character is actually
     entered). So, when the location is 0, need to check if button should be enabled or not, to
     ensure that upon entering first character, it's enabled, and upon deleting first character
     (when it is the only character), it's disabled
     */
    
    //TODO: CLEAN UP
    if(range.location == 0)
    {
        if(textField == _textFieldTitle)
        {
            if((string.length > 0 || _textFieldTitle.text.length > 1) && _textFieldDuration.text.length > 0 && _textFieldCategory.text.length > 0)
            {
                _buttonSubmit.enabled = YES;
            }
            else
            {
                _buttonSubmit.enabled = NO;
            }
        }
        else if(textField == _textFieldDuration)
        {
            if((string.length > 0 || _textFieldDuration.text.length > 1) && _textFieldTitle.text.length > 0 && _textFieldCategory.text.length > 0)
            {
                _buttonSubmit.enabled = YES;
            }
            else
            {
                _buttonSubmit.enabled = NO;
            }
        }
        else if(textField == _textFieldCategory)
        {
            if((string.length > 0 || _textFieldCategory.text.length > 1) && _textFieldTitle.text.length > 0 && _textFieldDuration.text.length > 0)
            {
                _buttonSubmit.enabled = YES;
            }
            else
            {
                _buttonSubmit.enabled = NO;
            }
        }
    }
    //Otherwise, do normal check
    else
    {
        _buttonSubmit.enabled = [self enableDoneButton];
    }
    return true;
}

//If the user taps deadline field, display a date picker
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //If the text field is deadline, display a date picker
    if(textField == _textFieldDeadline)
    {
        //If deadline wasn't already picked, set it to current date
        if(!_deadline)
        {
            self.textFieldDeadline.text = [self.formatter stringFromDate:[NSDate date]];
        }
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        [datePicker setDate:[NSDate date]];
        [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
        [self.textFieldDeadline setInputView:datePicker];
    }
}

//Updates deadline text field when a date is picked in the date picker
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.textFieldDeadline.inputView;
    self.textFieldDeadline.text = [self.formatter stringFromDate:picker.date];
    _deadline = picker.date;
}

//If all required text fields filled in, done button should be enabled
-(BOOL)enableDoneButton
{
    BOOL enabled;
    if(_textFieldTitle.text.length > 0 && _textFieldDuration.text.length > 0 && _textFieldCategory.text.length > 0)
    {
        enabled = YES;
    }
    else
    {
        enabled = NO;
    }
    return enabled;
}

@end
