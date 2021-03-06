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
#import "GITUserActionViewController.h"
#import "GITSmartScheduler.h"

@implementation GITAddTaskViewController

#pragma mark - viewDidLoad/viewDidAppear

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Task";
    
    // Set up pickers content, default picker values and default label text
    [self setUpPriorityPicker];
    [self setUpDurationPicker];
    [self setUpDeadlinePicker];
    
    // Set "None" as chosen category
    [self setUpCategory];
    
    // Be notified of keyboard opening/closing
    [self signUpForKeyboardNotifications];
    
    // Make dictionary to store all info UserAction view may need
    _taskInfoDictionary = [[NSMutableDictionary alloc] init];
    
    //If in edit mode, fill in all fields that are known about existing task
    if(_editMode)
    {
        _taskTitle = _task.title;
        _duration = _task.duration;
        _categoryTitle = (_task.belongsTo).title;
        _description = _task.event_description;
        _priority = _task.priority;
        _deadline = _task.deadline;
        
        [_taskInfoDictionary setObject:_task forKey:@"task"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // If any fields filled in before select date screen, upon returning to this screen, show those filled in fields
    if(_taskTitle)
    {
        self.textFieldTitle.text = _taskTitle;
    }
    if(_duration)
    {
        //Format picker content from _duration info
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
    
    if(_editMode)
    {
        
        // Ensures done button enabled even if you don't make changes (since required info obviously already there, if the task was made already)
        _buttonSubmit.enabled = [self enableDoneButton];
    }
}


#pragma mark - Constructors

- (GITTaskManager *)taskManager
{
    if(!_taskManager)
    {
        _taskManager = [[GITTaskManager alloc] init];
    }
    return _taskManager;
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


#pragma mark - Set up

/**
 Sets list of priorty options & makes no priority the default selection
 */
-(void)setUpPriorityPicker
{
    // Make list of priority options
    _priorityOptionsArray = [[NSArray alloc] initWithObjects:@"None",@"Low ",@"Medium",@"High", nil];
    
    // Select "None" as default priority
    [_pickerViewPriority selectRow:0 inComponent:0 animated:NO];
    _labelPriority.text = @"None";
}

/**
 Sets list of duration options & makes 1 hour the default selection
 */
-(void)setUpDurationPicker
{
    // Make list of duration hour options
    _durationHourOptionsArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], nil];
    
    // Make list of duration minute options
    _durationMinutesOptionsArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:5],[NSNumber numberWithInt:10],[NSNumber numberWithInt:15],[NSNumber numberWithInt:20], [NSNumber numberWithInt:25], [NSNumber numberWithInt:30],[NSNumber numberWithInt:35], [NSNumber numberWithInt:40], [NSNumber numberWithInt:45],[NSNumber numberWithInt:50], [NSNumber numberWithInt:55], nil];
    
    // Select 1 hour, 0 minutes as default duration
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

/**
 Register to know when keyboard will show
 */
- (void)signUpForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Scheduling

- (IBAction)scheduleTaskButtonPressed:(id)sender;
{
    // Gather task information inputted by user
    [self gatherInput];
    
    // Send to task manager to validate info. Display alert any info is invalid
    NSError *validationError;
    BOOL isValid = [self.taskManager isTaskInfoValidForDeadline:_deadline categoryTitle:_categoryTitle error:&validationError];
    
    // If not valid, show error
    if (!isValid)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error"
                                                       message: validationError.localizedDescription
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
    
    // All info valid
    else
    {
        // Make smart scheduling suggestion for new task via smart scheduler
        if(!_editMode)
        {
            // Do beginning steps for scheduling a task
            [self scheduleTask];
        }
        else
        {
            // Edit existing task
            [self editTask];
        }
    }
}

/**
 Collects information for title and description that the user entered in preparation for creating the task. All other values assigned already by this point (from pickers or category screen).
 */
- (void)gatherInput
{
    // Gather text field input
    _taskTitle = _textFieldTitle.text;
    _description = _textFieldDescription.text;
    
    // If no priority chosen, use default priority of low
    if(!_priority)
    {
        _priority = [NSNumber numberWithInt:1];
    }
    
    // If no duration chosen, use default duration of 1 hour, 0 minutes
    if(!_duration)
    {
        _duration = [NSNumber numberWithInt:60];
    }
    
    // If no category chosen, use default category of "None"
    if(!_categoryTitle)
    {
        _categoryTitle = @"None";
    }
    [_taskInfoDictionary setObject:_taskTitle forKey:@"title"];
    [_taskInfoDictionary setObject:_description forKey:@"description"];
    [_taskInfoDictionary setObject:_priority forKey:@"priority"];
    [_taskInfoDictionary setObject:_duration forKey:@"duration"];
    [_taskInfoDictionary setObject:_categoryTitle forKey:@"categoryTitle"];
}

/**
 Gets a smart scheduling suggestion, and calls segue to go to UserActionVC
 */
- (void) scheduleTask
{
    // Get day period for inputted priority
    int dayPeriod = [self.taskManager getDayPeriodForTaskPriority:_priority];
    
    // Get date suggestion from smart scheduler
    NSDate *dateSuggestion = [[GITSmartScheduler sharedScheduler] makeTimeSuggestionForDuration:_duration andCategoryTitle:_categoryTitle withinDayPeriod:dayPeriod forDeadline:_deadline];
    
    // Save to dictionary
    [_taskInfoDictionary setObject:dateSuggestion forKey:@"dateSuggestion"];
    
    // Send to UserActionVC to display
    if(dateSuggestion)
    {
        // Present UserActionVC as modal view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kGITMainStoryboard bundle:nil];
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:kGITNavControllerUserAction];
        GITUserActionViewController *vc = [nav.viewControllers objectAtIndex:0];
        vc.taskInfoDictionary = _taskInfoDictionary;
        vc.taskHappening = NO;
        vc.editedTask = _task;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    
    // Display Error
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"All time slots for the appropriate time period overlap with existing event. Please make room in your schedule, lower the priority, or change the deadline, and then try again." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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
        BOOL deadlineChanged = !([_deadline compare:_task.deadline] == NSOrderedSame) || (_deadline && !_task.deadline) || (!_deadline && _task.deadline);
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
    //Node, since just checking new time period, don't need to exclude any events (since original task already excluded by only looking at time period outside of it)
    BOOL overlap = [[GITSmartScheduler sharedScheduler] overlapWithinDuration:durationChangeNumber andDate:_task.end_time excludingEvent:nil];
    
    return !overlap;
}

#pragma mark - Saving Task
/**
 Simplest case of edit. Just saving new info without getting new smart scheduling suggestion.
 */
-(void)saveTask
{
    [self.taskManager makeTaskAndSaveWithTitle:_taskTitle startDate:_task.start_time description:_description duration:_duration categoryTitle:_categoryTitle deadline:_deadline priority:_priority forTask:_task];
    
    [self.navigationController popToRootViewControllerAnimated:true];
}

#pragma mark - Alert View

/**
 Handles the user accepting or rejecting smart scheduling suggestion
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
     Changed duration and got conflict - asked if you'd like to reschedule
     Options - Yes or Cancel
     */
    if([alertView.title isEqualToString:kGITAlertEditingError])
    {
        if(buttonIndex == 1)
        {
            [self scheduleTask];
        }
    }
    /*
     Get alert when you edited if you changed category, deadline or priority asking if you'd like a new smart scheduling suggestion
     Options - Yes or No(and keep task info)
     */
    else if([alertView.title isEqualToString:kGITAlertOfferNewSuggestion])
    {
        //Wants new smart scheduling suggestion
        if(buttonIndex == 1)
        {
            [self scheduleTask];
        }
        //Wants to keep current time
        else if(buttonIndex == 2)
        {
            [self saveTask];
        }
    }
}

# pragma mark - Table view delegate/datasource

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


#pragma mark - Deadline

/**
 Updates deadline label when a date is picked in the deadline date picker
 */
- (IBAction)deadlineChanged:(UIDatePicker *)sender {
    
    // Get deadline selected
    NSDate *selectedDeadline = sender.date;
    
    // Set text field text
    _textFieldDeadline.text = [self.formatter stringFromDate:selectedDeadline];
    
    // Save to property and taskInfo dictionary
    _deadline = selectedDeadline;
    [_taskInfoDictionary setObject:_deadline forKey:@"deadline"];
    
    // Check if done button should be enabled
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

#pragma mark - Text field delegate
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

#pragma mark - Category delegate

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


#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushCategory])
    {
        // Get reference to the destination view controller
        GITCategoryViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
    else if([[segue identifier] isEqualToString:kGITSeguePushUserAction])
    {
        GITUserActionViewController *vc = [segue destinationViewController];
        vc.taskInfoDictionary = _taskInfoDictionary;
    }
}

@end
