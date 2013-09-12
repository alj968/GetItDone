//
//  EventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

/**
 Allows user to add an event to the calendar.
 */
@interface AddEventViewController : UITableViewController

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Event to be added or edited
 */
@property (nonatomic, strong) Event *event;
/**
 Specifies if the event is in edit mode, or create mode(default)
 */
@property (nonatomic) bool editMode;
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
 The button with text "submit" that gathers the user's input to form an event, and saves
 this event to the database
 */
- (IBAction)addEventButton:(id)sender;

@end
