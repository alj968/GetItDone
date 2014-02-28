//
//  GITManualTaskViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 2/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITManualTaskViewController.h"

@implementation GITManualTaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPickers];
    self.title = @"Select Times";
}

- (GITSmartSchedulingViewController *)smartScheduler
{
    if(!_smartScheduler)
    {
        _smartScheduler = [[GITSmartSchedulingViewController alloc] init];
    }
    return _smartScheduler;
}

//TODO: This lets you pick a time that overlaps with another event!! FIX!
//TODO: THEN see if you can have event 2-3 and 3-4
- (void)setUpPickers
{
    _datePickerStartTime.minimumDate = [NSDate date];
    //End time can't be earlier than one minute from current time
    _datePickerEndTime.minimumDate = [[NSDate date] dateByAddingTimeInterval:60];
    
    //Set start time to be current time
    _startTime = [NSDate date];
    [_datePickerStartTime setDate:_startTime];
    _labelStartTime.text = [self.formatter stringFromDate:_startTime];
    
    //Set end time to be one hour from current time
    _endTime = [[NSDate date] dateByAddingTimeInterval:60*60];
    [_datePickerEndTime setDate:_endTime];
    _labelEndTime.text = [self.formatter stringFromDate:_endTime];
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

- (IBAction)startPickerChanged:(UIDatePicker *)sender
{
    NSDate *selectedStartTime = sender.date;
    _labelStartTime.text = [self.formatter stringFromDate:selectedStartTime];
    _startTime = selectedStartTime;
    if(!_endTimeChosen)
    {
        //If end time not chosen, set it for one hour after start time
        _endTime = [_startTime dateByAddingTimeInterval:60*60];
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

- (IBAction)doneButtonPressed:(id)sender {
    //Make sure this time doesn't overlap with other times
    double timeIntervalMinutes = ([_endTime timeIntervalSinceDate:_startTime] / 60);
    NSNumber *duration = [NSNumber numberWithDouble:timeIntervalMinutes];
    BOOL overlap = [self.smartScheduler isTimeSlotTakenWithDuration:duration andDate:_startTime];
    if(overlap)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kGITAlertEditingError message:@"These selections cause a scheduling conflict. Please choose a new start and/or end time." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        //Send selections to AddTaskViewController
        if(self.delegate && [self.delegate respondsToSelector:@selector(manualTaskViewController:finishedWithStartTime:andEndTime:)])
        {
            [self.delegate manualTaskViewController:self finishedWithStartTime:_startTime andEndTime:_endTime];
        }
    }
}

/**
 This method handles increasing the height of the picker cells to show each picker when appropriate
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.row == kGITManualStartPickerIndex)
    {
        if(_datePickerStartIsShowing)
        {
            height = kGITManualStartEndPickerHeight;
        }
        else
        {
            height = 0.0f;
        }
    }
    else if(indexPath.row == kGITManualEndPickerIndex)
    {
        if(_datePickerEndIsShowing)
        {
            height = kGITManualStartEndPickerHeight;
        }
        else
        {
            height = 0.0f;
        }
    }
    return height;
}

/**
 Notices if a picker cell was selected, and if so, shows/hides the picker
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == kGITManualStartPickerIndex - 1)
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
    else if(indexPath.row == kGITManualEndPickerIndex - 1)
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - My picker methods

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


@end
