//
//  GITSelectDate.h
//  GetItDone
//
//  Created by Amanda Jones on 9/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GITAddEventViewController.h"

/**
 Where user chooses start and end time for their event
 */
@interface GITSelectDate : UITableViewController
{
    /**
     Formats dates. E.g. "Sept 6, 2013 1:00 PM"
     */
    NSDateFormatter *formatter;
}
/**
 The date picker control
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *pickerDate;

/**
 The start time of the event
 */
@property (strong, nonatomic) NSDate *startTime;
/**
 The end time of the event
 */
@property (strong, nonatomic) NSDate *endTime;

/**
 Label for the start time
 */
@property (strong, nonatomic) IBOutlet UILabel *labelStart;
/**
 Label for the end time
 */
@property (strong, nonatomic) IBOutlet UILabel *labelEnd;

/**
 Specifies if the end time row of the table was selected, so the
 chosen date could be filled in for the end time label
 */
@property  (nonatomic) bool endSelected;

/**
 Specifies if an end time was already chosen. If not, the 
 end time will be automatically set to one hour after start 
 time. If it has been chosen, it will keep that selection until
 end time is changed, even if start time changes in the meantime
 */
@property (nonatomic) bool endTimeChosen;

/**
 Indicates that a date and time was selected in the picker
 */
- (IBAction)dateSelected:(id)sender;

/**
 Indicated that user is done making date selection
 */
- (IBAction)doneButtonPressed:(id)sender;

/**
 Reference to the GITAddEventViewController from which this vc comes
 */
@property (nonatomic, strong)GITAddEventViewController *addVC;


@end
