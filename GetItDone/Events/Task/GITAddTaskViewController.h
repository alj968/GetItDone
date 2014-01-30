//
//  GITSmartScheduleInputViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITTask.h"
#import "GITDatebaseHelper.h"
#import "GITTaskManager.h"
#import "GITTimeSlotManager.h"
#import "GITSmartSchedulingViewController.h"

/**
 Allows user to enter task information for it to be smart scheduled.
 */
@interface GITAddTaskViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

/**
 Appointment to be added or edited
 */
@property (nonatomic, strong) GITTask *task;
/**
 Date suggested for the task from the Smart Scheduling View Controller
 */
@property (nonatomic, strong) NSDate *dateSuggestion;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The entity manager for task
 */
@property (nonatomic, strong) GITTaskManager *taskManager;
/**
 The entity manager for time slot
 */
@property (nonatomic, strong) GITTimeSlotManager *timeSlotManager;
/**
 Smart scheduling view controller to handle the smart scheduling
 */
@property (nonatomic, strong) GITSmartSchedulingViewController *smartScheduler;

/**For the below properties, once the done button pressed,
 e.g. when user is done adding/editing info, these properties
 are what give the task entity its attributes
 */
@property (strong, nonatomic) NSString *taskTitle;
/**
 The duration of the task
 */
@property (strong, nonatomic) NSNumber *duration;
/**
 The title of the category of the task
 */
@property (strong, nonatomic) NSString *categoryTitle;
/**
 The description of the task - optional
 */
@property (strong, nonatomic) NSString *description;
/**
 The task's numeric priority - optional
 */
@property (strong, nonatomic) NSNumber *priority;
/**
 Deadline - date before which task must be completed - optional
 */
@property (strong, nonatomic) NSDate *deadline;
/**
 Specifies if the appointment is in edit mode, or create mode(default)
 */
@property (nonatomic) BOOL editMode;
/**
 The textbox for the title of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 The textbox for the  description of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 The label to display the category chosen (default choice as placeholder)
 */
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
/**
 Picker view to allow user to choose 1, 2 or 3 or none for priority
 */
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewPriority;
/**
 The label to display the priority chosen (default choice as placeholder)
 */
@property (strong, nonatomic) IBOutlet UILabel *labelPriority;
/**
 The table view cell containing the priority picker
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellPriorityPicker;
/**
 Boolean to keep track of if the priority picker is currently showing or not
 */
@property (nonatomic, assign) BOOL pickerPriorityIsShowing;
/**
 Array of values for priority picker view
 */
@property (strong, nonatomic) NSArray *priorityOptionsArray;
/**
 Picker view to allow user duration value in minutes
 */
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewDuration;
/**
 The label to display the duration chosen (default choice as placeholder)
 */
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
/**
 The table view cell containing the duration picker
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellDurationPicker;
/**
 Boolean to keep track of if the duration picker is currently showing or not
 */
@property (nonatomic, assign) BOOL pickerDurationIsShowing;
/**
 Array of values for hours in duration picker view
 */
@property (strong, nonatomic) NSArray *durationHourOptionsArray;
/**
 Array of values for minutes in duration picker view
 */
@property (strong, nonatomic) NSArray *durationMinutesOptionsArray;
/**
 Date picker view to allow user to choose deadline date
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerDeadline;
/**
 The hour value selected for the duration
 */
@property (strong, nonatomic) NSNumber *durationHours;
/**
 The minute value selected for the duration
 */
@property (strong, nonatomic) NSNumber *durationMinutes;
/**
 The label to display the deadline chosen (none as placeholder)
 */
@property (strong, nonatomic) IBOutlet UILabel *labelDeadline;
/**
 The table view cell containing the deadline date picker
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellDeadlinePicker;
/**
 Boolean to keep track of if the deadline date picker is currently showing or not
 */
@property (nonatomic, assign) BOOL pickerDeadlineIsShowing;
/**
 Keeps track of which text field is being edited, to handle when to show/hide keyboard and pickers
 */
@property (strong, nonatomic) UITextField *activeTextField;
/**
 IBOutlet for the "done" button. Only enabled when required text fields are filled in.
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonSubmit;
/**
 The button with text "submit" that gathers the user's input to form a task, and saves
 this task to the database
 */
- (IBAction)scheduleTaskButtonPressed:(id)sender;
/**
 When a value is selected in the deadline date picker, this method is called so that the deadline property can be set
 */
- (IBAction)deadlineChanged:(UIDatePicker *)sender;
@end
