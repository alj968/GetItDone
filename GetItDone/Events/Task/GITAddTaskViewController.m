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
    [self setUpPriorityPicker];
}

/**
 If any of the text fields are filled in before going to select date screen, makes sure that when you come back to this screen, that previously selected data will be in the textfields. Also ensures that if user coming in from edit mode, known information about the task appears
 */
- (void)viewDidAppear:(BOOL)animated
{
    if(_editMode)
    {
        _taskTitle = _task.title;
        _duration = _task.duration;
        //TODO: Fix this once category data object implemented
        //_category = _task.category;
        _description = _task.event_description;
        _priority = _task.priority;
        _deadline = _task.deadline;
    }
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
        //TODO: Check this
        [_pickerViewPriority selectRow:[_priority integerValue] inComponent:0 animated:NO];
    }
    if(_deadline)
    {
        self.textFieldDeadline.text = [self.formatter stringFromDate:_deadline];
    }
}

- (GITTaskManager *)taskManager
{
    if(!_taskManager)
    {
        _taskManager = [[GITTaskManager alloc] init];
    }
    return _taskManager;
}

- (GITSmartSchedulingViewController *)smartScheduler
{
    if(!_smartScheduler)
    {
        _smartScheduler = [[GITSmartSchedulingViewController alloc] init];
    }
    return _smartScheduler;
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

-(void)setUpPriorityPicker
{
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:@"None",@"High",@"Medium",@"Low", nil];
    [_pickerViewPriority selectRow:0 inComponent:0 animated:NO];
}

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{
    //Set properties with text field text
    _taskTitle = _textFieldTitle.text;
    _duration = [NSNumber numberWithDouble:[_textFieldDuration.text doubleValue]];
    _category = _textFieldCategory.text;
    _description = _textFieldDescription.text;
    //Priority asigned when picker has priority picked. "None" selected by default
    //Deadline assigned when date picker has a date picked
    
    if(!_editMode) {
        //Send to task manager to validate info. Display alert any info is invalid
        NSString *errorMessage = [self.taskManager validateTaskInfoForDuration:_duration deadline:_deadline];
        
        //If invalid info, display alert with the message
        if(errorMessage.length >0)
        {
            [self showAlertWithTitle:@"Saved failed" andMessage:errorMessage];
        }
        //If all info valid, make smart scheduling suggestion
        else
        {
            //Make smart scheduling suggestion
            _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration];
            [self showTimeSuggestionAlertWithDate:_dateSuggestion];
        }
    }
    
    //In edit mode
    else
    {
        //TODO: To be filled in when edit task use case is implemented
    }
}

/**
 Displays the time suggestion and allows the user to click buttons to accept, reject or cancel the suggestion.
 @param date The date to be suggested
 */
-(void)showTimeSuggestionAlertWithDate:(NSDate *)date
{
    NSString *randomDateString = [self.formatter stringFromDate:date];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Suggested Task Time"
                                                   message: randomDateString
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Accept",@"Reject",nil];
    [alert show];
}

/**
 Displays an alert with the specified title and message.
 @param title The title to be displayed
 @param message The message to be displayed
 */
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: title
                                                   message: message
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}

/**
 Handles the user accepting or rejecting smart scheduling suggestion
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL taskScheduled = NO;
    //Accepted suggestion
    if (buttonIndex == 1)
    {
        //Schedule task
        taskScheduled = [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_dateSuggestion description:_description duration:_duration category:_category deadline:_deadline priority:_priority forTask:NULL];
        
        //Go back to monthly calendar
        if(taskScheduled)
        {
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else
        {
            [self showAlertWithTitle:@"Save Failed" andMessage:@"Could not save task. Please try again."];
        }
    }
    //Rejected suggestion
    else if(buttonIndex == 2)
    {
        _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration];
        [self showTimeSuggestionAlertWithDate:_dateSuggestion];
    }
}

/**
 If the user taps deadline field, display a date picker
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //If the text field is deadline, display a date picker
    if(textField == _textFieldDeadline)
    {
        //If deadline wasn't already picked, set it to current date
        if(!_deadline)
        {
            self.textFieldDeadline.text = [self.formatter stringFromDate:[NSDate date]];
            _deadline = [NSDate date];
        }
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        [datePicker setDate:[NSDate date]];
        [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
        [self.textFieldDeadline setInputView:datePicker];
    }
}

/**
 Updates deadline text field when a date is picked in the date picker
 */
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.textFieldDeadline.inputView;
    self.textFieldDeadline.text = [self.formatter stringFromDate:picker.date];
    _deadline = picker.date;
}

/**
 Ensures done button is enabled only when all required text fields filled in.
 */
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

/**
 Futher ensures correct enabling/disabling to done button. For button to be enabled, title, duration and category must be provided.
 */
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

#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_priorityOptionsArray count];
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_priorityOptionsArray objectAtIndex:row];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    NSString *chosenPriorityString = [_priorityOptionsArray objectAtIndex:row];
    if([chosenPriorityString isEqualToString:@"Low"])
    {
        _priority = [NSNumber numberWithInt:1];
    }
    else if([chosenPriorityString isEqualToString:@"Medium"])
    {
        _priority = [NSNumber numberWithInt:2];
    }
    else if([chosenPriorityString isEqualToString:@"High"])
    {
        _priority = [NSNumber numberWithInt:3];
    }
}

@end
