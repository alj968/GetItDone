//
//  GITSelectDate.h
//  GetItDone
//
//  Created by Amanda Jones on 9/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Event.h"
#import "GITAddAppointmentViewController.h"
@class GITSelectDateViewController;

/**
 Defines the methods in the SelectDateDelegate
 */
@protocol GITSelectDateDelegate <NSObject>

/**
 Sets the start time & end time selected, using the selections,
 in the GITAddEventViewController
 @param controller The select date view controller
 @param start The start time chosen
 @param end The end time chosen
 */
- (void)selectDateViewController:(GITSelectDateViewController *)controller finishedWithStartTime:(NSDate *)start endTime:(NSDate *)end;

@end

/**
 Where user chooses start and end time for their event
 */
@interface GITSelectDateViewController : UITableViewController
{
    /**
     Formats dates. E.g. "Sept 6, 2013 1:00 PM"
     */
    NSDateFormatter *_formatter;
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
@property  (nonatomic) BOOL endSelected;
/**
 Specifies if an end time was already chosen. If not, the
 end time will be automatically set to one hour after start
 time. If it has been chosen, it will keep that selection until
 end time is changed, even if start time changes in the meantime
 */
@property (nonatomic) BOOL endTimeChosen;
/**
 Delegate for Select Date Controller
 */
@property (nonatomic) id<GITSelectDateDelegate> delegate;
/**
 Indicates that a date and time was selected in the picker
 */
- (IBAction)dateSelected:(id)sender;
/**
 Indicated that user is done making date selection
 */
- (IBAction)doneButtonPressed:(id)sender;

@end
