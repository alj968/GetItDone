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
    /**TODO: IMPLEMENT LATER
     if(_deadline)
     self.textFieldDeadline.text = _deadline;
     */
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
    //TODO: Implement later
    //_deadline = _textFieldDeadline.text;
    
    if(!_editMode) {
        //Get task input
        //Can request a task be smart scheduled as long as all required input is present
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
    //TODO: Implement what to do when a task gets edited here
}

-(void)makeTimeSuggestion
{
    //TODO: Right now assuming this is 7, but this will change when priority and deadline are incorporated - OR should this be user input?
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

//REQUIRED: TITLE, DURATION, CATEGORY
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
        else
        {
            _buttonSubmit.enabled = NO;
        }
    }
    //Otherwise, do normal check
    else
    {
        _buttonSubmit.enabled = [self enableDoneButton];
    }
    return true;
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
