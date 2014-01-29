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
    [self setUpDurationPicker];
    
    [self signUpForKeyboardNotifications];
    
    //TODO Think of proper place to put this later
    self.labelCategory.text = @"None";
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
        //TODO Set picker to be the value
    }
    if(_categoryTitle)
    {
        //Figure out what order in the array the title is, and that'll give you it's row in the picker view
        //TODO: Set the label to be this title I think? Check
        self.labelCategory.text = _categoryTitle;
        //TODO Have this selected on next screen (category screen)?
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
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:@"None",@"High",@"Medium",@"Low", nil];
    
    //Select "None" as default priority
    [_pickerViewPriority selectRow:0 inComponent:0 animated:NO];
    
    //Set up label to have default priority displayed
    _labelPriority.text = @"None";
    _priority = [NSNumber numberWithInt:1];
}

-(void)setUpDurationPicker
{
    //TODO: Later make this have two columns, one for hour and one for minutes
    //Make list of priority options
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:10],[NSNumber numberWithInt:15],[NSNumber numberWithInt:30],[NSNumber numberWithInt:45],[NSNumber numberWithInt:60], nil];
    
    //Select 60 as default duration
    [_pickerViewPriority selectRow:5 inComponent:0 animated:NO];
    
    //Set up label to have default priority displayed
    _labelDuration.text = @"60 minutes";
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
 //TODO fix this line Category already asigned when picker has category picked. "None" selected by default
 Deadline already assigned when date picker has a date picked
 */
- (void)gatherInput
{
    //Set properties with text field text
    _taskTitle = _textFieldTitle.text;
    //TODO: Remove once it's set from picker
    //_duration = [NSNumber numberWithDouble:[_textFieldDuration.text doubleValue]];
    _description = _textFieldDescription.text;
}

/**
 Automatically make smart scheduling suggestion for a new task
 */
- (void)makeNewTask
{
    //TODO: Later handle what happens if this doesn't return a date (and do this everywhere it's called)
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:_priority]];
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
    //TODO: Later handle what happens if this doesn't return a date
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:_priority]];
    [self showTimeSuggestionAlertWithDate:_dateSuggestion];
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
    else if(pickerView == _pickerViewDuration)
    {
        return [_durationOptionsArray count];
    }
    return 0;
}

//TODO: MOVE LATER TO CONSTANTS FILE
#define kGITPickerPrioritySection 2
#define kGITPickerPriorityIndex 1
#define kGITPriorityPickerCellHeight 164

#define kGITPickerDurationSection 1
#define kGITPickerDurationIndex 1
//todo: MAYBE WANT TO CHANGE CELL  HEIGHT LATER
#define kGITDurationPickerCellHeight 164
//TODO: LATER COMMENT THESE METHOD AND PUT THESE TABLE METHODS PROPER PLACE
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.section == kGITPickerPrioritySection)
    {
        if(indexPath.row == kGITPickerPriorityIndex)
        {
            if(self.pickerPriorityIsShowing)
            {
                height = kGITPriorityPickerCellHeight;
            }
            else
            {
                height = 0.0f;
            }
        }
    }
    else if(indexPath.section == kGITPickerDurationSection)
    {
        if(indexPath.row == kGITPickerDurationIndex)
        {
            if(self.pickerDurationIsShowing)
            {
                height = kGITDurationPickerCellHeight;
            }
            else
            {
                height = 0.0f;
            }
        }
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kGITPickerPrioritySection)
    {
        if(indexPath.row == kGITPickerPriorityIndex - 1)
        {
            if(self.pickerPriorityIsShowing)
            {
                [self hidePriorityPickerCell];
            }
            else
            {
                [self showPriorityPickerCell];
            }
        }
    }
    else if(indexPath.section == kGITPickerDurationSection)
    {
        if(indexPath.row == kGITPickerDurationIndex - 1)
        {
            if(self.pickerDurationIsShowing)
            {
                [self hideDurationPickerCell];
            }
            else
            {
                [self showDurationPickerCell];
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showPriorityPickerCell
{
    self.pickerPriorityIsShowing = YES;
    
    //Call these so the height for the cell can be changed
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    //Hide keyboard
    [self.activeTextField resignFirstResponder];
    
    //Make label text red
    [_labelPriority setTextColor:[UIColor redColor]];
}

- (void)hidePriorityPickerCell
{
    self.pickerPriorityIsShowing = NO;
    
    //Call these so the height for the cell can be changed
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    //Make label text black again
    [_labelPriority setTextColor:[UIColor blackColor]];
}

- (void)signUpForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow
{
    if(self.pickerPriorityIsShowing)
    {
        [self hidePriorityPickerCell];
    }
}

//TODO: TABLE METHODS END. MOVE SECTION TO PROPER PLACE

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        return [_priorityOptionsArray objectAtIndex:row];
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
        _labelPriority.text = [_priorityOptionsArray objectAtIndex:row];
    }
}

#pragma mark Deadline picker methods

/**
 If the user taps deadline field, display a date picker
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    
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
