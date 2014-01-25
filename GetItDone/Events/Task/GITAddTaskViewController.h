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
#import "GITCategoryManager.h"
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
 The entity manager for category
 */
@property (nonatomic, strong) GITCategoryManager *categoryManager;
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
 The textbox for the duration of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDuration;
/**
 The textbox for the  description of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 The textbox for the deadline - date before which task must be completed
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeadline;
/**
 Picker view to allow user to choose a pre-existing category, or add a new one
 */
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewCategory;
/**
 Array of values for category picker view. Contains exsiting categories, and the option to make a new one
 */
@property (strong, nonatomic) NSMutableArray *categoryOptionsArray;
/**
 Picker view to allow user to choose 1, 2 or 3 or none for priority
 */
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewPriority;
/**
 Array of values for priority picker view
 */
@property (strong, nonatomic) NSArray *priorityOptionsArray;
/**
 IBOutlet for the "done" button. Only enabled when required text fields are filled in.
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonSubmit;
/**
 The button with text "submit" that gathers the user's input to form an appointment, and saves
 this appointment to the database
 */
- (IBAction)scheduleTaskButtonPressed:(id)sender;

@end
