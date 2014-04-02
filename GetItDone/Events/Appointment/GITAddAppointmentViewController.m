//
//  EventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITAddAppointmentViewController.h"
#import "GITCalendarViewController.h"
#import "GITSmartScheduler.h"

@implementation GITAddAppointmentViewController

#pragma mark - View did load/view did appear
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setUpPickers];
    [self signUpForKeyboardNotifications];
    self.title = @"Appointment";
}

- (void)viewDidAppear:(BOOL)animated
{
    /*
     If any text fields filled in before select date screen,
     fill these fields in upon coming back to this screen
     Also ensures that if you're coming in from edit mode, text appears
     */
    if(_editMode)
    {
        _appointmentTitle = _appointment.title;
        _description = _appointment.event_description;
        _startTime = _appointment.start_time;
        _endTime = _appointment.end_time;
    }
    if(_appointmentTitle)
    {
        self.textFieldTitle.text = _appointmentTitle;
    }
    if(_startTime)
    {
        _labelStartTime.text = [self.formatter stringFromDate:_startTime];
        [_datePickerStartTime setDate:_startTime];
    }
    if(_endTime)
    {
        _labelEndTime.text = [self.formatter stringFromDate:_endTime];
        [_datePickerEndTime setDate:_endTime];
    }
    if(_description)
    {
        self.textFieldDescription.text = _description;
    }
    
    // Ensures done button enabled even if in edit mode & you don't make changes (since required info obviously already there, if the appointent was made already)
    _buttonDone.enabled = [self enableDoneButton];
}

#pragma mark - Set up

- (void)setUpPickers
{
    _datePickerStartTime.minimumDate = [NSDate date];
    //End time can't be earlier than one minute from current time
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oneMinuteFromNowComponents = [[NSDateComponents alloc] init];
    oneMinuteFromNowComponents.minute = 1;
    NSDate *datePickerEnd = [calendar dateByAddingComponents:oneMinuteFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    _datePickerEndTime.minimumDate = datePickerEnd;
    
    if(!_editMode)
    {
        //Set start time to be current time
        _startTime = [NSDate date];
        [_datePickerStartTime setDate:_startTime];
        _labelStartTime.text = [self.formatter stringFromDate:_startTime];
        
        //Set end time to be one hour from current time
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *oneHourFromNowComponents = [[NSDateComponents alloc] init];
        oneHourFromNowComponents.hour = 1;
        _endTime = [calendar dateByAddingComponents:oneHourFromNowComponents
                                                          toDate:_startTime
                                                         options:0];
        [_datePickerEndTime setDate:_endTime];
        _labelEndTime.text = [self.formatter stringFromDate:_endTime];
    }
}

#pragma mark - Constructors

- (GITAppointmentManager *)appointmentManager
{
    if(!_appointmentManager)
    {
        _appointmentManager = [[GITAppointmentManager alloc] init];
    }
    return _appointmentManager;
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

#pragma mark - Add appointment


-(BOOL)timeChanged
{
    // Do check to ensure appointment exists
    if(_editMode)
    {
        // Check start time change
        if(![_appointment.start_time compare:_startTime] == NSOrderedSame)
        {
            return YES;
        }
        // Check end time change
        else if(![_appointment.end_time compare:_endTime] == NSOrderedSame)
        {
            return YES;
        }
    }
    return false;
}

- (IBAction)addAppointmentButtonPressed:(id)sender
{
    //Check if time chosen overlaps with another event
    double timeIntervalMinutes = ([_endTime timeIntervalSinceDate:_startTime] / 60);
    NSNumber *duration = [NSNumber numberWithDouble:timeIntervalMinutes];
    BOOL overlap = [[GITSmartScheduler sharedScheduler] overlapWithinDuration:duration andDate:_startTime];
    //TODO - issue where you change the time to be within previous time (eg before event 8-9, now *;15-8:45, going to get issue)
    if(overlap && (!_editMode || (_editMode && [self timeChanged])))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kGITAlertEditingError message:@"These selections cause a scheduling conflict. Please choose a new start and/or end time." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        /*
         For this button to be enbaled, we know all reuqired fields filled in
         Start and end date assigned upon leaving select date screen
         */
        _appointmentTitle = _textFieldTitle.text;
        _description = _textFieldDescription.text;
        _appointment = [self.appointmentManager makeAppointmentAndSaveWithTitle:_appointmentTitle startDate:_startTime endDate:_endTime description:_description forAppointment:_appointment];
        
        if(_appointment)
        {
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Save Failed"
                                                           message: @"Could not save appointment. Please try again."
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - Picker methods

- (IBAction)startPickerChanged:(UIDatePicker *)sender
{
    NSDate *selectedStartTime = sender.date;
    _labelStartTime.text = [self.formatter stringFromDate:selectedStartTime];
    _startTime = selectedStartTime;
    if(!_endTimeChosen)
    {
        //If end time not chosen, set it for one hour after start time
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *oneHourFromStartComponents = [[NSDateComponents alloc] init];
        oneHourFromStartComponents.hour = 1;
        _endTime = [calendar dateByAddingComponents:oneHourFromStartComponents
                                             toDate:_startTime
                                            options:0];
        [_datePickerEndTime setDate:_endTime];
        _labelEndTime.text = [_formatter stringFromDate: _endTime];
    }
    //Ensure end date is at least one minute later than start date
    _datePickerEndTime.minimumDate = [_startTime dateByAddingTimeInterval:60];
}

- (IBAction)endPickerChanged:(UIDatePicker *)sender
{
    NSDate *selectedEndTime = sender.date;
    _labelEndTime.text = [self.formatter stringFromDate:selectedEndTime];
    _endTime = selectedEndTime;
    _endTimeChosen = YES;
    
    //Ensure start date is at least one minute earlier than end date
    _datePickerStartTime.maximumDate = [_endTime dateByAddingTimeInterval:-60];
}

#pragma mark - "Done" button enabling
//If all required text fields filled in, done button should be enabled
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
        if((string.length > 0 || _textFieldTitle.text.length > 1))
        {
            _buttonDone.enabled = YES;
        }
        else
        {
            _buttonDone.enabled = NO;
        }
    }
    //Otherwise, do normal check
    else
    {
        _buttonDone.enabled = [self enableDoneButton];
    }
    return true;
}

#pragma mark - TableView delegate/data source
/**
 Notices if a picker cell was selected, and if so, shows/hides the picker
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kGITStartEndPickerSection)
    {
        if(indexPath.row == kGITStartPickerIndex - 1)
        {
            if(_datePickerStartIsShowing)
            {
                [self hidePickerCellForPicker:@"Start"];
            }
            else
            {
                [self showPickerCellForPicker:@"Start"];
            }
        }
        else if(indexPath.row == kGITEndPickerIndex - 1)
        {
            if(_datePickerEndIsShowing)
            {
                [self hidePickerCellForPicker:@"End"];
            }
            else
            {
                [self showPickerCellForPicker:@"End"];
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Showing/hiding picker view

/**
 This method handles increasing the height of the picker cells to show each picker when appropriate
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.section == kGITStartEndPickerSection)
    {
        if(indexPath.row == kGITStartPickerIndex)
        {
            if(_datePickerStartIsShowing)
            {
                height = kGITStartEndPickerHeight;
            }
            else
            {
                height = 0.0f;
            }
        }
        else if(indexPath.row == kGITPickerDeadlineIndex)
        {
            if(_datePickerEndIsShowing)
            {
                height = kGITStartEndPickerHeight;
            }
            else
            {
                height = 0.0f;
            }
        }
        
    }
    return height;
}

- (void)showPickerCellForPicker:(NSString *)picker
{
    if([picker isEqualToString:@"Start"])
    {
        _datePickerStartIsShowing = YES;
        //Make label text red
        [_labelStartTime setTextColor:[UIColor redColor]];
    }
    else if([picker isEqualToString:@"End"])
    {
        _datePickerEndIsShowing = YES;
        //Make label text red
        [_labelEndTime setTextColor:[UIColor redColor]];
    }
    
    //Call these so the height for the cell can be changed
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    //Hide keyboard
    [self.activeTextField resignFirstResponder];
}

- (void)hidePickerCellForPicker:(NSString *)picker
{
    if([picker isEqualToString:@"Start"])
    {
        _datePickerStartIsShowing = NO;
        //Make label text black again
        [_labelStartTime setTextColor:[UIColor blackColor]];
    }
    else if([picker isEqualToString:@"End"])
    {
        _datePickerEndIsShowing = NO;
        //Make label text black again
        [_labelEndTime setTextColor:[UIColor blackColor]];
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
    if(_datePickerStartIsShowing)
    {
        [self hidePickerCellForPicker:@"Start"];
    }
    if(_datePickerEndIsShowing)
    {
        [self hidePickerCellForPicker:@"End"];
    }
}
/**
 Keep track of active text field so it can give up keyboard when a picker opens
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

@end
