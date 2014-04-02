//
//  GITSmartScheduleInputViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITTask.h"
#import "GITDatabaseHelper.h"
#import "GITTaskManager.h"
#import "GITTimeSlotManager.h"
#import "GITCategoryViewController.h"

/**
 Allows user to enter task information for it to be smart scheduled.
 */
@interface GITAddTaskViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GITCategoryDelegate>

/**
 Task to be added or edited
 */
@property (nonatomic, strong) GITTask *task;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The entity manager for task
 */
@property (nonatomic, strong) GITTaskManager *taskManager;
/**For the below properties, once the done button pressed,
 e.g. when user is done adding/editing info, these properties
 are what give the task entity its attributes
 */
/**
 The title of the task
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
 Boolean to keep track of if the title was changed in edit mode, so it stays the new choice
 */
@property (nonatomic) BOOL categoryEdited;
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
 Contains information about the task that the next screen, UserActionVC, would need. This includes info about the task inputted by the user, the task created, and the date suggested
 */
@property (strong, nonatomic) NSMutableDictionary *taskInfoDictionary;
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
 The textfield to display the deadline chosen
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeadline;
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
