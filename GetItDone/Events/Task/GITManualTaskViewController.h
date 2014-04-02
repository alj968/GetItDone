//
//  GITManualTaskViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 2/10/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GITManualTaskViewController;

/**
 Defines the methods in the ManualTaskDelegate
 */
@protocol GITManualTaskDelegate <NSObject, UITableViewDelegate, UITableViewDataSource>

/**
 Sets the start and end time selected, using the selections,
 in the GITAddTaskViewController
 @param controller The manual task view controller
 @param start The start time chosen
 @param end The end time chosen
 */
- (void)manualTaskViewController:(GITManualTaskViewController *)controller finishedWithStartTime:(NSDate *)start andEndTime:(NSDate *)end;

@end

/**
 The view controller that allows the user to specify their own start and end time for a task. The other information for this task was filled out on the AddTaskViewController previously.
 */
@interface GITManualTaskViewController : UITableViewController
/**
 Delegate for Manual Task Controller
 */
@property (nonatomic) id<GITManualTaskDelegate> delegate;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The task that is being edited, that the user is manually choosing a new time for. Important to have so you can pass it to the overlap method. (So if task was originally 1-2 pm, the user can manually schedule it from 1:15 to 1:45 and not get overlap error).
 */
@property (nonatomic, strong) GITTask *editedTask;
/**
 The start time selected for the task
 */
@property (nonatomic, strong) NSDate *startTime;
/**
 The label for the start date chosen(including time) of the task
 */
@property (strong, nonatomic) IBOutlet UILabel *labelStartTime;
/**
 The date picker for the start time
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerStartTime;
/**
 The cell containing the picker for the start time
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellStartDatePicker;
/**
 The end time selected for the task
 */
@property (nonatomic, strong) NSDate *endTime;
/**
 The label for the end date chosen (including time) of the task
 */
@property (strong, nonatomic) IBOutlet UILabel *labelEndTime;
/**
 The date picker for the end time
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerEndTime;
/**
 The cell containing the picker for the end time
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellEndDatePicker;
/**
 Boolean to keep track of if the start time date picker is currently showing or not
 */
@property (nonatomic, assign) BOOL datePickerStartIsShowing;
/**
 Boolean to keep track of if the end time date picker is currently showing or not
 */
@property (nonatomic, assign) BOOL datePickerEndIsShowing;
/**
 Specifies if an end time was already chosen. If not, the
 end time will be automatically set to one hour after start
 time. If it has been chosen, it will keep that selection until
 end time is changed, even if start time changes in the meantime
 */
@property (nonatomic) BOOL endTimeChosen;

/**
 Method called when the start time date picker changes
 */
- (IBAction)startPickerChanged:(UIDatePicker *)sender;
/**
 Method called when the end time date picker changes
 */
- (IBAction)endPickerChanged:(UIDatePicker *)sender;
/**
 When this button is pressed, the start time and end time should be selected. This method calls the delegate method to have AddTaskViewController handle the selections
 */
- (IBAction)doneButtonPressed:(id)sender;
@end
