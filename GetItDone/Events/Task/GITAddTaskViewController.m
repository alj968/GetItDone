//
//  GITSmartScheduleInputViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITAddTaskViewController.h"
#import "NSDate+Utilities.h"
#import "GITTimeSlotTableViewController.h"
#import "GITProjectConstants.h"

@implementation GITAddTaskViewController

#pragma mark Set up

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Task";
    //Set up pickers
    [self setUpPriorityPicker];
    [self setUpCategoryPicker];
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
        _categoryTitle = (_task.belongsTo).title;
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
    if(_categoryTitle)
    {
        //Figure out what order in the array the title is, and that'll give you it's row in the picker view
        int row = [_categoryOptionsArray indexOfObject:_categoryTitle];
        [_pickerViewCategory selectRow:row inComponent:0 animated:NO];
    }
    if(_description)
    {
        self.textFieldDescription.text = _description;
    }
    if(_priority)
    {
        [_pickerViewPriority selectRow:([_priority integerValue] - 1) inComponent:0 animated:NO];
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

-(GITCategoryManager *)categoryManager
{
    if(!_categoryManager)
    {
        _categoryManager = [[GITCategoryManager alloc] init];
    }
    return _categoryManager;
}

-(GITTimeSlotManager *)timeSlotManager
{
    if(!_timeSlotManager)
    {
        _timeSlotManager = [[GITTimeSlotManager alloc] init];
    }
    return _timeSlotManager;
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

/**
 Sets list of priorty options & makes no priority the default selection
 */
-(void)setUpPriorityPicker
{
    //Make list of priority options
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:@"None",@"3: High",@"2: Medium",@"1: Low", nil];
    
    //Select "None" as default priority
    [_pickerViewPriority selectRow:0 inComponent:0 animated:NO];
}

/**
 Sets list of category options, using categories stored in the database, plus the option to create a new category
 */
-(void)setUpCategoryPicker
{
    //Ask category manager to get all categories
    _categoryOptionsArray = [[self.categoryManager getAllCategoryTitles] mutableCopy];
    
    //Add option to add a new category
    [_categoryOptionsArray addObject:@"Create New Category"];
    
    //In database set up, "None" is first category, and make this default selection
    [_pickerViewCategory selectRow:0 inComponent:0 animated:NO];
}


#pragma mark Scheduling

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{
    [self gatherInput];
    
    //Send to task manager to validate info. Display alert any info is invalid
    NSError *validationError;
    //Pass error by reference
    BOOL isValid = [self.taskManager isTaskInfoValidForDuration:_duration deadline:_deadline error:&validationError];
    if (!isValid)
    {
        [self showSimpleAlertWithTitle:@"Error" andMessage:validationError.localizedDescription];
    }
    //All info valid
    else
    {
        if(!_editMode)
        {
            if(!_categoryTitle)
            {
                _categoryTitle = @"None";
            }
            [self makeNewTask];
        }
        else
        {
            [self editTask];
        }
    }
}

/**
 Collects information for title, duration and description that the user entered in preparation for creating the task.
 Priority already asigned when picker has priority picked. "None" selected by default
 Category already asigned when picker has category picked. "None" selected by default
 Deadline already assigned when date picker has a date picked
 */
- (void)gatherInput
{
    //Set properties with text field text
    _taskTitle = _textFieldTitle.text;
    _duration = [NSNumber numberWithDouble:[_textFieldDuration.text doubleValue]];
    _description = _textFieldDescription.text;
}

/**
 Automatically make smart scheduling suggestion for a new task
 */
- (void)makeNewTask
{
    //TODO: Use priority to figure out day period
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:4];
    [self showTimeSuggestionAlertWithDate:_dateSuggestion];
}

/**
 Displays the time suggestion and allows the user to click buttons to accept, reject or cancel the suggestion.
 @param date The date to be suggested
 */
-(void)showTimeSuggestionAlertWithDate:(NSDate *)date
{
    NSString *randomDateString = [self.formatter stringFromDate:date];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: kGITAlertTimeSuggestion
                                                   message: randomDateString
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Accept",@"Reject",nil];
    [alert show];
}

/**
 If in edit mode, check if crucial information (TODO: Fill in...) was changed, and if so, automatically make smart scheduling suggestion and delete old scheduling. Else, ask user if they'd like to reschedule
 */
- (void)editTask
{
    //TODO: Implement
}


#pragma mark Alert View Methods

/**
 Handles the user accepting or rejecting smart scheduling suggestion
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:kGITAlertTimeSuggestion])
    {
        if (buttonIndex == 1)
        {
            [self acceptSuggestion];
        }
        else if(buttonIndex == 2)
        {
            [self rejectSuggestion];
        }
    }
    else if([alertView.title isEqualToString:kGITAlertNewCategory])
    {
        //If category submitted
        if(buttonIndex == 1)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [self makeNewCategoryWithTitle:textField.text];
        }
    }
}

/**
 Called when the user accepts a smart scheduling suggestion.
 Asks the task manager to create the task.
 If it was successfully created, returns the user to the home screen.
 Otherwise, dispalys an errror message.
 */
- (void)acceptSuggestion
{
    BOOL taskScheduled = NO;
    taskScheduled = [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_dateSuggestion description:_description duration:_duration categoryTitle:_categoryTitle deadline:_deadline priority:_priority forTask:NULL];
    
    if(taskScheduled)
    {
        //Have time slot manager change appropriate time slots
        [self.timeSlotManager adjustTimeSlotsForDate:_dateSuggestion andCategoryTitle:_categoryTitle forUserAction:kGITUserActionAccept];
        
        //TODO: When done testing, remove below and add bottom part back
        GITTimeSlotTableViewController *vc = [[GITTimeSlotTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:NO];
        //Go back to calendar view
        //[self.navigationController popToRootViewControllerAnimated:true];
    }
    else
    {
        [self showSimpleAlertWithTitle:@"Save Failed" andMessage:@"Could not save task. Please try again."];
    }
}

/**
 Called when the user rejects a smart scheduling suggestion.
 Generates a new smart scheduling suggestion and displays it.
 */
- (void) rejectSuggestion
{
    //Register reject
    [self.timeSlotManager adjustTimeSlotsForDate:_dateSuggestion andCategoryTitle:_categoryTitle forUserAction:kGITUserActionReject];
    
    //Make new suggestion
    //TODO: Later use priority to figure out day period param
    //TODO: Later handle what happens if this doesn't return a date (and do this everywhere it's called)
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:4];
    [self showTimeSuggestionAlertWithDate:_dateSuggestion];
}

/**
 Makes a new category with the given title.
 Sets the member variable of category title,
 calls the category manager ot create the category in the datbase,
 and adjusts the picker view for category accordingly
 */
- (void)makeNewCategoryWithTitle:(NSString *)categoryTitle
{
    //Set member variable
    _categoryTitle = categoryTitle;
    
    //Make category via category manager
    [self.categoryManager addCategoryWithTitle:_categoryTitle];
    
    //Set up picker view
    [_categoryOptionsArray insertObject:_categoryTitle atIndex:(_categoryOptionsArray.count - 1)];
    [_pickerViewCategory reloadAllComponents];
    [_pickerViewPriority selectRow:(_categoryOptionsArray.count) inComponent:0 animated:NO];
}


#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        return [_priorityOptionsArray count];
    }
    //Category picker view
    else
    {
        return [_categoryOptionsArray count];
    }
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        return [_priorityOptionsArray objectAtIndex:row];
    }
    //Category picker view
    else
    {
        return [_categoryOptionsArray objectAtIndex:row];
    }
}

/**
 If the user chooses from the pickerview, it calls this function
 @param row Row selected
 @param component Component the selected row is in
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        //Low = 1, Medium = 2, High = 3
        _priority = [NSNumber numberWithInt:(row+1)];
    }
    //Category picker view
    else
    {
        NSString *chosenCategoryString = [_categoryOptionsArray objectAtIndex:row];
        
        if([chosenCategoryString isEqualToString:@"Create New Category"])
        {
            //If user selects create new category, then doesn't choose one, makes category "None"
            _categoryTitle = @"None";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kGITAlertNewCategory
                                                                message:@"Enter New Category Title"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        }
        else
        {
            _categoryTitle = chosenCategoryString;
        }
    }
}

#pragma mark Deadline picker methods

/**
 If the user taps deadline field, display a date picker
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
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

#pragma mark "Done" button enabling
/**
 Ensures done button is enabled only when all required text fields filled in.
 */
-(BOOL)enableDoneButton
{
    BOOL enabled;
    if(_textFieldTitle.text.length > 0 && _textFieldDuration.text.length > 0)
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
            if((string.length > 0 || _textFieldTitle.text.length > 1) && _textFieldDuration.text.length > 0)
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
            if((string.length > 0 || _textFieldDuration.text.length > 1) && _textFieldTitle.text.length > 0)
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

#pragma mark Helper methods
/**
 Displays an alert with the specified title and message.
 @param title The title to be displayed
 @param message The message to be displayed
 */
-(void)showSimpleAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: title
                                                   message: message
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}


@end
