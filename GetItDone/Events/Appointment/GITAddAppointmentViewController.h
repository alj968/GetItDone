//
//  EventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITAppointmentManager.h"

/**
 Allows user to add an appointment to the calendar.
 */
@interface GITAddAppointmentViewController : UITableViewController <UITextFieldDelegate>

/**
 Appointment to be added or edited
 */ 
@property (nonatomic, strong) GITAppointment *appointment;
/**
 The entity manager for appointment
 */
@property (nonatomic, strong) GITAppointmentManager *appointmentManager;
/**
 Smart scheduling view controller to handle the smart scheduling
 */
@property (nonatomic, strong) GITSmartSchedulingViewController *smartScheduler;
 /**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**For the below properties, once the done button pressed,
 e.g. when user is done adding/editing info, these properties
 are what give the appointment entity its attributes
 */
/*
 Keeps track of the appointment title entered
 */
@property (nonatomic, strong) NSString *appointmentTitle;
/**
 The start time selected in GITSelectDate
 */
@property (nonatomic, strong) NSDate *startTime;
/**
 The end time selected in GITSelectDate
 */
@property (nonatomic, strong) NSDate *endTime;
/**
 Keeps track of the appointment description entered
 */
@property (nonatomic, strong) NSString *description;
/**
 Specifies if the appointment is in edit mode, or create mode(default)
 */
@property (nonatomic) BOOL editMode;
/**
 The textbox for the title of the appointment
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 The textbox for the description of the appointment
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 The label for the start date chosen(including time) of the appointment
 */
@property (strong, nonatomic) IBOutlet UILabel *labelStartTime;
/**
 The label for the end date chosen (including time) of the appointment
 */
@property (strong, nonatomic) IBOutlet UILabel *labelEndTime;
/**
 The date picker for the start time
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerStartTime;
/**
 The date picker for the end time
 */
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerEndTime;
/**
 The cell containing the picker for the start time
 */
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCellStartDatePicker;
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
 Keeps track of which text field is being edited, to handle when to show/hide keyboard and pickers
 */
@property (strong, nonatomic) UITextField *activeTextField;
/**
 Specifies if an end time was already chosen. If not, the
 end time will be automatically set to one hour after start
 time. If it has been chosen, it will keep that selection until
 end time is changed, even if start time changes in the meantime
 */
@property (nonatomic) BOOL endTimeChosen;
/**
 IBOutlet for the "done" button. Only enabled when required text fields are filled in.
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
/**
 The button with text "submit" that gathers the user's input to form an appointment, and saves
 this appointment to the database
 */
- (IBAction)addAppointmentButtonPressed:(id)sender;
/**
 Method called when the start time date picker changes
 */
- (IBAction)startPickerChanged:(UIDatePicker *)sender;
/**
 Method called when the end time date picker changes
 */
- (IBAction)endPickerChanged:(UIDatePicker *)sender;

@end
