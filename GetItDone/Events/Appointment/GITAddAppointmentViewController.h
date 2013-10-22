//
//  EventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatebaseHelper.h"

/**
 Allows user to add an appointment to the calendar.
 */
@interface GITAddAppointmentViewController : UITableViewController

/**
 Appointment to be added or edited
 */
@property (nonatomic, strong) Appointment *appointment;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;

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
 The textbox for the start date (including time) of the appointment
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldStartTime;
/**
 The textbox for the end date (including time) of the appointment
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndTime;
/**
 The textbox for the description of the appointment
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 Keeps track of the last field that was edited before pressing done. textFieldDidEndEditing
 may not get called for this field, so this ensures the text field's input is saved
 */
@property (nonatomic, strong) UITextField *lastEditedField;
/**
 IBOutlet for the "done" button. Only enabled when required text fields are filled in.
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
/**
 The button with text "submit" that gathers the user's input to form an appointment, and saves
 this appointment to the database
 */
- (IBAction)addAppointmentButtonPressed:(id)sender;

@end
