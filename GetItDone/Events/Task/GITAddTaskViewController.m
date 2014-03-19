//
//  GITSmartScheduleInputViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITAddTaskViewController.h"
#import "GITTimeSlotTableViewController.h"
#import "GITProjectConstants.h"

@implementation GITAddTaskViewController

#pragma mark - Set up
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Task";
    
    //Set up pickers
    [self setUpPriorityPicker];
    [self setUpDurationPicker];
    [self setUpDeadlinePicker];
    
    [self setUpCategory];
    [self signUpForKeyboardNotifications];
    
    if(_editMode)
    {
        _taskTitle = _task.title;
        _duration = _task.duration;
        _categoryTitle = (_task.belongsTo).title;
        _description = _task.event_description;
        _priority = _task.priority;
        _deadline = _task.deadline;
    }
}

/**
 If any of the text fields are filled in before going to select date screen, makes sure that when you come back to this screen, that previously selected data will be in the textfields. Also ensures that if user coming in from edit mode, known information about the task appears
 */
- (void)viewDidAppear:(BOOL)animated
{
    if(_taskTitle)
    {
        self.textFieldTitle.text = _taskTitle;
    }
    if(_duration)
    {
        int durationInt = [_duration intValue];
        int hoursInt = durationInt/60;
        int minutesInt = durationInt%60;
        _labelDuration.text = [NSString stringWithFormat:@"%d hrs, %d min",hoursInt,minutesInt];
        
        [_pickerViewDuration selectRow:hoursInt inComponent:0 animated:NO];
        [_pickerViewDuration selectRow:(minutesInt/5) inComponent:1 animated:NO];
    }
    if(_categoryTitle)
    {
        _labelCategory.text = _categoryTitle;
    }
    if(_description)
    {
        self.textFieldDescription.text = _description;
    }
    if(_priority)
    {
        _labelPriority.text = [_priorityOptionsArray objectAtIndex:[_priority integerValue]];
        [_pickerViewPriority selectRow:([_priority integerValue]) inComponent:0 animated:NO];
    }
    if(_deadline)
    {
        _textFieldDeadline.text = [self.formatter stringFromDate:_deadline];
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

/**
 Sets list of priorty options & makes no priority the default selection
 */
-(void)setUpPriorityPicker
{
    //Make list of priority options
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:@"None",@"Low ",@"Medium",@"High", nil];
    
    //Select "None" as default priority
    [_pickerViewPriority selectRow:0 inComponent:0 animated:NO];
    _labelPriority.text = @"None";
}

/**
 Sets list of duration options & makes 1 hour the default selection
 */
-(void)setUpDurationPicker
{
    //Make list of priority options
    _durationHourOptionsArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], nil];
    _durationMinutesOptionsArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:5],[NSNumber numberWithInt:10],[NSNumber numberWithInt:15],[NSNumber numberWithInt:20], [NSNumber numberWithInt:25], [NSNumber numberWithInt:30],[NSNumber numberWithInt:35], [NSNumber numberWithInt:40], [NSNumber numberWithInt:45],[NSNumber numberWithInt:50], [NSNumber numberWithInt:55], nil];
    
    //Select 1 hour as default duration
    [_pickerViewDuration selectRow:1 inComponent:0 animated:NO];
    [_pickerViewDuration selectRow:0 inComponent:1 animated:NO];
    _labelDuration.text = @"1 hrs 0 min";
    _durationHours = [NSNumber numberWithInt:1];
    _durationMinutes = [NSNumber numberWithInt:0];
}

/**
 Ensures the deadline selected can be no earlier than current time
 */
-(void)setUpDeadlinePicker
{
    _datePickerDeadline.minimumDate = [NSDate date];
    if(_editMode && _task.deadline)
    {
        _datePickerDeadline.date = _task.deadline;
    }
}

/**
 Sets label and categoryTitle property to be the defualt category, "None"
 */
-(void)setUpCategory
{
    _labelCategory.text = @"None";
}


#pragma mark - Scheduling

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{
    [self gatherInput];
    
    //Send to task manager to validate info. Display alert any info is invalid
    NSError *validationError;
    //Pass error by reference
    BOOL isValid = [self.taskManager isTaskInfoValidForDeadline:_deadline categoryTitle:_categoryTitle error:&validationError];
    if (!isValid)
    {
        [self showSimpleAlertWithTitle:@"Error" andMessage:validationError.localizedDescription];
    }
    //All info valid
    else
    {
        if(!_editMode)
        {
            [self makeSmartSchedulingSuggestion];
        }
        else
        {
            [self editTask];
        }
    }
}

/**
 Collects information for title and description that the user entered in preparation for creating the task. All other values assigned already by this point (from pickers or category screen).
 */
- (void)gatherInput
{
    _taskTitle = _textFieldTitle.text;
    _description = _textFieldDescription.text;
    if(!_priority)
    {
        _priority = [NSNumber numberWithInt:1];
    }
    if(!_duration)
    {
        _duration = [NSNumber numberWithInt:60];
    }
    if(!_categoryTitle)
    {
        _categoryTitle = @"None";
    }
}

/**
 Automatically make smart scheduling suggestion for a new task
 */
- (void)makeSmartSchedulingSuggestion
{
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:_priority]];
    if(_dateSuggestion)
    {
        [self showTimeSuggestionAlertWithDate:_dateSuggestion];
    }
    else
    {
        [self showSimpleAlertWithTitle:@"Error" andMessage:@"All time slots for the appropriate time period overlap with existing event. Please make room in your schedule, lower the priority, or change the deadline, and then try again."];
    }
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
                                         otherButtonTitles:@"Accept",@"Reject",@"I'll choose my own time",nil];
    [alert show];
}

#pragma mark - Editing a Task
/**
 If in edit mode, check if crucial information was changed, and if so, automatically make smart scheduling suggestion and delete old scheduling. Else, ask user if they'd like to reschedule
 */
- (void)editTask
{
    BOOL editOkay = YES;
    /**
     Duration change:
     If duration decreased, this is fine.
     If duration increased, check if there's now overlap with another event
     */
    if([_duration compare:_task.duration] == NSOrderedDescending)
    {
        editOkay = [self editedDurationOk];
        if(!editOkay)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kGITAlertEditingError message:@"New duration causes scheduling conflict. Would you like to reschedule?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
    }
    if(editOkay)
    {
        /**
         Category, priority or deadline change:
         Ask user if they'd like a new suggestion based on their new data.
         */
        BOOL categoryChanged = ![_categoryTitle isEqualToString:_task.belongsTo.title];
        BOOL priorityChanged = ![_priority isEqualToNumber:_task.priority];
        BOOL deadlineChanged = !([_deadline compare:_task.deadline] == NSOrderedSame);
        if(categoryChanged || priorityChanged || deadlineChanged)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kGITAlertOfferNewSuggestion message:@"Would you like a new smart scheduling suggestion, based on the edited information?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",@"No", nil];
            [alert show];
        }
        /**
         If you got to this point:
         Duration okay or didn't change, and/or title and/or description changed
         Can just save new task info
        */
        else
        {
            [self saveTask];
        }
    }
}

/**
 If the duration of a task was increased, verify that this does not result in an overlap with another existing event
 */
-(BOOL)editedDurationOk
{
    //Get duration change
    int durationChange = [_duration intValue] - [_task.duration intValue];
    NSNumber *durationChangeNumber = [NSNumber numberWithInt:durationChange];
    
    //Check for overlap in the extended time period
    BOOL overlap = [self.smartScheduler overlapWithinDuration:durationChangeNumber andDate:_task.end_time];
    
    return !overlap;
}

#pragma mark - Saving Task
-(void)saveTask
{
    [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_task.start_time description:_description duration:_duration categoryTitle:_categoryTitle deadline:_deadline priority:_priority forTask:_task];
    [self.navigationController popToRootViewControllerAnimated:true];
}

#pragma mark - Alert View Methods

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
        else if(buttonIndex == 3)
        {
            [self manuallyScheduleTask];
        }
    }
    else if([alertView.title isEqualToString:kGITAlertEditingError])
    {
        //Wants new smart scheduling suggestion
        if(buttonIndex == 1)
        {
            [self makeSmartSchedulingSuggestion];
        }
    }
    else if([alertView.title isEqualToString:kGITAlertOfferNewSuggestion])
    {
        //Wants new smart scheduling suggestion
        if(buttonIndex == 1)
        {
            [self makeSmartSchedulingSuggestion];
        }
        //Wants to keep current time
        else if(buttonIndex == 2)
        {
            [self saveTask];
        }
    }
}

#pragma mark - Post-suggestion Actions

/**
 Called when the user accepts a smart scheduling suggestion.
 Asks the task manager to create the task.
 If it was successfully created, returns the user to the home screen.
 Otherwise, dispalys an errror message.
 */
- (void)acceptSuggestion
{
    _task = [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_dateSuggestion description:_description duration:_duration categoryTitle:_categoryTitle deadline:_deadline priority:_priority forTask:_task];
    
    if(_task)
    {
        //Have smart scheduler handle smart scheduling-related actions resulting from the accept
        [self.smartScheduler userActionTaken:kGITUserActionAccept forTask:_task];
        
        //TODO: remove later, FOR TESTING - Show time slot table screen
        GITTimeSlotTableViewController *vc = [[GITTimeSlotTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
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
    //Have smart scheduler handle smart scheduling-related actions resulting from the accept
    [self.smartScheduler rejectionForTaskTitle:_taskTitle categoryTitle:_categoryTitle startTime:_dateSuggestion duration:_duration];
    
    //Make new suggestion
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:[self.taskManager getDayPeriodForTaskPriority:_priority]];
    if(_dateSuggestion)
    {
        [self showTimeSuggestionAlertWithDate:_dateSuggestion];
    }
    else
    {
        [self showSimpleAlertWithTitle:@"Error" andMessage:@"All time slots for the appropriate time period overlap with existing event. Please make room in your schedule, lower the priority, or change the deadline, and then try again."];
    };
}

/**
 Called when the user requests to manually schedule a task after seeing the smart scheduling suggestion.
 */
-(void) manuallyScheduleTask
{
    //Count as reject
    [self.smartScheduler rejectionForTaskTitle:_taskTitle categoryTitle:_categoryTitle startTime:_dateSuggestion duration:_duration];
    
    //Let user manually schedule
    [self performSegueWithIdentifier:kGITSeguePushManualTask sender:self];
}

# pragma mark - Table view methods

/**
 This method handles increasing the height of the picker cells to show each picker when appropriate
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.section == kGITPickerPriorityDeadlineSection)
    {
        if(indexPath.row == kGITPickerPriorityIndex)
        {
            if(_pickerPriorityIsShowing)
            {
                height = kGITPriorityPickerCellHeight;
            }
            else
            {
                height = 0.0f;
            }
        }
        else if(indexPath.row == kGITPickerDeadlineIndex)
        {
            if(_pickerDeadlineIsShowing)
            {
                height = kGITDeadlinePickerCellHeight;
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
            if(_pickerDurationIsShowing)
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

/**
 Notices if a picker cell was selected, and if so, shows/hides the picker
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kGITPickerPriorityDeadlineSection)
    {
        if(indexPath.row == kGITPickerPriorityIndex - 1)
        {
            if(_pickerPriorityIsShowing)
            {
                [self hidePickerCellForPicker:@"Priority"];
            }
            else
            {
                [self showPickerCellForPicker:@"Priority"];
            }
        }
        else if(indexPath.row == kGITPickerDeadlineIndex - 1)
        {
            if(_pickerDeadlineIsShowing)
            {
                [self hidePickerCellForPicker:@"Deadline"];
            }
            else
            {
                [self showPickerCellForPicker:@"Deadline"];
            }
        }
    }
    else if(indexPath.section == kGITPickerDurationSection)
    {
        if(indexPath.row == kGITPickerDurationIndex - 1)
        {
            if(_pickerDurationIsShowing)
            {
                [self hidePickerCellForPicker:@"Duration"];
            }
            else
            {
                [self showPickerCellForPicker:@"Duration"];
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Showing/hiding picker

- (void)showPickerCellForPicker:(NSString *)picker
{
    if([picker isEqualToString:@"Priority"])
    {
        _pickerPriorityIsShowing = YES;
        //Make label text red
        [_labelPriority setTextColor:[UIColor redColor]];
    }
    else if ([picker isEqualToString:@"Duration"])
    {
        _pickerDurationIsShowing = YES;
        //Make label text red
        [_labelDuration setTextColor:[UIColor redColor]];
    }
    else if([picker isEqualToString:@"Deadline"])
    {
        _pickerDeadlineIsShowing = YES;
        //Make label text red
        [_textFieldDeadline setTextColor:[UIColor redColor]];
    }
    
    //Call these so the height for the cell can be changed
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    //Hide keyboard
    [self.activeTextField resignFirstResponder];
}

- (void)hidePickerCellForPicker:(NSString *)picker
{
    if([picker isEqualToString:@"Priority"])
    {
        _pickerPriorityIsShowing = NO;
        //Make label text black again
        [_labelPriority setTextColor:[UIColor blackColor]];
    }
    else if ([picker isEqualToString:@"Duration"])
    {
        _pickerDurationIsShowing = NO;
        //Make label text black again
        [_labelDuration setTextColor:[UIColor blackColor]];
    }
    else if([picker isEqualToString:@"Deadline"])
    {
        _pickerDeadlineIsShowing = NO;
        //Make label text black again
        [_textFieldDeadline setTextColor:[UIColor blackColor]];
    }
    //Call these so the height for the cell can be changed
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)signUpForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow
{
    if(_pickerPriorityIsShowing)
    {
        [self hidePickerCellForPicker:@"Priority"];
    }
    if(_pickerDurationIsShowing)
    {
        [self hidePickerCellForPicker:@"Duration"];
    }
    if(_pickerDeadlineIsShowing)
    {
        [self hidePickerCellForPicker:@"Deadline"];
    }
}


#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView == _pickerViewDuration)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        return [_priorityOptionsArray count];
    }
    else if(pickerView == _pickerViewDuration)
    {
        if(component == 0)
        {
            return [_durationHourOptionsArray count];
        }
        else if(component == 1)
        {
            return [_durationMinutesOptionsArray count];
        }
    }
    return 0;
}

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
    else if(pickerView == _pickerViewDuration)
    {
        if(component == 0)
        {
            return [[_durationHourOptionsArray objectAtIndex:row] stringValue];
        }
        else if(component == 1)
        {
            return [[_durationMinutesOptionsArray objectAtIndex:row] stringValue];
            
        }
    }
    return nil;
}

/**
 If the user chooses from the pickerview, it calls this function
 @param row Row selected
 @param component Component the selected row is in
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _buttonSubmit.enabled = [self enableDoneButton];
    if(pickerView == _pickerViewPriority)
    {
        //Priority equivalents: None = 1, Low = 1, Medium = 2, High = 3
        if(row ==0)
        {
            _priority = [NSNumber numberWithInt:1];
        }
        else
        {
            _priority = [NSNumber numberWithInt:row];
        }
        _labelPriority.text = [_priorityOptionsArray objectAtIndex:row];
    }
    else if(pickerView == _pickerViewDuration)
    {
        if(component == 0)
        {
            _durationHours = [_durationHourOptionsArray objectAtIndex:row];
            
        }
        else if(component == 1)
        {
            _durationMinutes = [_durationMinutesOptionsArray objectAtIndex:row];
            
        }
        int hoursInt = [_durationHours intValue];
        int minutesInt = [_durationMinutes intValue];
        int durationInt = (hoursInt * 60) + minutesInt;
        _duration = [NSNumber numberWithInt:durationInt];
        _labelDuration.text = [NSString stringWithFormat:@"%@ hrs, %@ min",_durationHours, _durationMinutes];
    }
}


#pragma mark - Deadline methods

/**
 Updates deadline label when a date is picked in the deadline date picker
 */
- (IBAction)deadlineChanged:(UIDatePicker *)sender {
    NSDate *selectedDeadline = sender.date;
    _textFieldDeadline.text = [self.formatter stringFromDate:selectedDeadline];
    _deadline = selectedDeadline;
    _buttonSubmit.enabled = [self enableDoneButton];
}

/**
 This method gets called when the user touches the clear button on the deadline text field.
 At this point,the deadline is being cleared, so _deadline's assignment should get erased also
 */
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _deadline = nil;
    _datePickerDeadline.date = [NSDate date];
    _buttonSubmit.enabled = [self enableDoneButton];
    return YES;
}

#pragma mark - "Done" button enabling

/**
 Ensures done button is enabled only when all required text fields filled in.
 */
-(BOOL)enableDoneButton
{
    BOOL enabled;
    if(_textFieldTitle.text.length > 0)
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
            if((string.length > 0 || _textFieldTitle.text.length > 1))
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


#pragma mark - Helper methods

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

#pragma mark - Text field delegate methods
/**
 Keep track of active text field so it can give up keyboard when a picker opens
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
    /*
     If text field is deadline, make sure user cannot type in their own deadline
     But, still want user to be able to click in the text field and have picker open/close,
     since it should open/close for anywhere in the cell
     */
    if(textField == _textFieldDeadline)
    {
        [self.view endEditing:YES];
        if(_pickerDeadlineIsShowing)
        {
            [self hidePickerCellForPicker:@"Deadline"];
        }
        else
        {
            [self showPickerCellForPicker:@"Deadline"];
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _textFieldTitle)
    {
        _taskTitle = textField.text;
    }
    else if(textField == _textFieldDescription)
    {
        _description = textField.text;
    }
}

#pragma mark - Category delegate methods

- (void)categoryViewController:(GITCategoryViewController *)controller finishedWithCategoryTitle:(NSString *)categoryTitle
{
    self.categoryTitle = categoryTitle;
    _labelCategory.text = _categoryTitle;
    if(_editMode)
    {
        _categoryEdited = YES;
    }
    _buttonSubmit.enabled = [self enableDoneButton];
}

#pragma mark - Manual task delegate methods

- (void)manualTaskViewController:(GITManualTaskViewController *)controller finishedWithStartTime:(NSDate *)start andEndTime:(NSDate *)end
{
    //Set duration
    double timeIntervalMinutes = ([end timeIntervalSinceDate:start] / 60);
    _duration = [NSNumber numberWithDouble:timeIntervalMinutes];
    
    //Set date suggestion to be the user's chosen start date
    _dateSuggestion = start;
    
    //With the above member variables set, acceptSuggestion can handle adding the task
    [self acceptSuggestion];
}


#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushCategory])
    {
        // Get reference to the destination view controller
        GITCategoryViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
    if([[segue identifier] isEqualToString:kGITSeguePushManualTask])
    {
        GITManualTaskViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}

@end
