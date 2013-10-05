//
//  EventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GITDatebaseHelper.h"

/**
 Allows user to add an event to the calendar.
 */
@interface GITAddEventViewController : UITableViewController

/**
 NSManagedObjectContext for core data
 */
//@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Event to be added or edited
 */
@property (nonatomic, strong) Event *event;

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
 are what give the event entity its attributes
 */
/**
 The start time selected in GITSelectDate
 */
@property (nonatomic, strong) NSDate *startTime;
/**
 The end time selected in GITSelectDate
 */
@property (nonatomic, strong) NSDate *endTime;
/*
 Keeps track of the event title entered
 */
@property (nonatomic, strong) NSString *eventTitle;
/*
 Keeps track of the event duration entered
 */
@property (nonatomic, strong) NSString *duration;
/*
 Keeps track of the task value entered
 */
@property (nonatomic, strong) NSString *task;


/**
 Specifies if the event is in edit mode, or create mode(default)
 */
@property (nonatomic) BOOL editMode;

/**
 The textbox for the title of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 The textbox for the start date (including time) of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldStartTime;
/**
 The textbox for the end date (including time) of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndTime;
/**
 The textbox for the duration of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDuration;
/**
 The textbox for specifying if an event is a task (i.e. can be rescheduled) or not
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTask;

/**
 Keeps track of the last field that was edited before pressing done. textFieldDidEndEditing
 may not get called for this field, so this ensures the text field's input is saved
 */
@property (nonatomic, strong) UITextField *lastEditedField;

/**
 The button with text "submit" that gathers the user's input to form an event, and saves
 this event to the database
 */
- (IBAction)addEventButtonPressed:(id)sender;

@end
