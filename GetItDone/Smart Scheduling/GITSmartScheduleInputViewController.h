//
//  GITSmartScheduleInputViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 10/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "GITDatebaseHelper.h"

/**
 Allows user to enter task information for it to be smart scheduled.
 */
@interface GITSmartScheduleInputViewController : UITableViewController

/**
 Appointment to be added or edited
 */
@property (nonatomic, strong) Task *task;
/**
 Random date found within a one week period of current date
 to be suggested
 */
@property (nonatomic, strong) NSDate *randomDate;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;
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
 The category of the task
 */
@property (strong, nonatomic) NSString *category;
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
 The textbox for the title of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 The textbox for the duration of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDuration;
/**
 The textbox for the category of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldCategory;
/**
 The textbox for the  description of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 The textbox for the task's numeric priority
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldPriority;
/**
 The textbox for the deadline - date before which task must be completed
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeadline;

//TODO: Implement edit task later
/**
 Specifies if the task is in edit mode, or create mode(default)
 *//*
@property (nonatomic) BOOL editMode;
*/

/**
 Keeps track of the last field that was edited before pressing done. textFieldDidEndEditing
 may not get called for this field, so this ensures the text field's input is saved
 */
@property (nonatomic, strong) UITextField *lastEditedField;
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
