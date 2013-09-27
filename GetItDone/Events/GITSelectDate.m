//
//  GITSelectDate.m
//  GetItDone
//
//  Created by Amanda Jones on 9/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITSelectDate.h"
#import "GITAddEventViewController.h"

@implementation GITSelectDate

- (void)viewDidLoad
{
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, y h:mm a"];
    }
    
    [self setUp];
}

-(void)setUp
{
    [self.pickerDate addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    
    //If start time isn't already chosen, e.g. if not editing an event,
    //set start time to be current time initially, and end time to be an hour from then
    if(!_startTime && !_endTime)
    {
        _startTime = self.pickerDate.date;
        _endTime = [_startTime dateByAddingTimeInterval:60*60];

    }
    else
    {
        self.pickerDate.date = _startTime;
    }
    
    self.labelStart.text = [formatter stringFromDate:_startTime];
    self.labelEnd.text = [formatter stringFromDate:_endTime];
    
    //Set first row as selected
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self setClearsSelectionOnViewWillAppear:NO];
}

- (IBAction)dateSelected:(id)sender {
    //If the date selected corresponds to the start time, set start time and its label
    //to match selection
    if(!_endSelected)
    {
        _startTime = _pickerDate.date;
        self.labelStart.text = [formatter stringFromDate:_startTime];
        
        //If end date wasn't already chosen, set the end date & its label to be one hour after start
        if(!_endTimeChosen)
        {
            _endTime = [_startTime dateByAddingTimeInterval:60*60];
            self.labelEnd.text = [formatter stringFromDate: _endTime];
        }
    }
    
    //Date selected corresponds to end time
    else
    {
        _endTime = _pickerDate.date;
        self.labelEnd.text = [formatter stringFromDate:_endTime];
        
        //Save that selection was made so end date no longer auto set to hour after start time
        _endTimeChosen = true;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Selected start time
    if(indexPath.row == 0)
    {
        [_pickerDate setDate:_startTime];
        _endSelected = false;
    }
    //Selected end time
    else if(indexPath.row == 1)
    {
        [_pickerDate setDate:_endTime];
        _endSelected = true;
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    _addVC.startTime = _startTime;
    _addVC.endTime = _endTime;
    
    [self.navigationController popViewControllerAnimated:true];
}

@end
