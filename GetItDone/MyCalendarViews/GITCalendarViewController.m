//
//  ViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/1/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITCalendarViewController.h"
#import "TSQCalendarView.h"
#import "GITCalendarDayViewController.h"
#import "GITAppDelegate.h"
#import "GITEventDetailsViewController.h"
#import "GITSetUpDatabase.h"
#import "GITAddTaskViewController.h"
#import "GITAddAppointmentViewController.h"

@implementation GITCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCalendarView];
    self.title = @"Calendar";
}

//TODO: Check what happens when access granted, then privacy settings changed, and access is denied - what happens to event list?
- (void)viewDidAppear:(BOOL)animated
{
    //Refetch iCal events
    [self setUpTable];
    [_tableViewEvents reloadData];
}

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

- (GITSyncingManager *)syncingManager
{
    if(!_syncingManager)
    {
        _syncingManager = [[GITSyncingManager alloc] init];
    }
    return _syncingManager;
}

-(NSDateFormatter *)formatter
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:kGITDefintionDateFormat];
    }
    return _formatter;
}

-(void)setUpCalendarView
{
    _calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 430)];
    
    NSDateComponents *comps1 = [[NSDateComponents alloc] init];
    [comps1 setDay:1];
    [comps1 setMonth:10];
    [comps1 setYear:2013];
    
    NSDateComponents *comps2 = [[NSDateComponents alloc] init];
    [comps2 setDay:6];
    [comps2 setMonth:9];
    [comps2 setYear:2050];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    //set in controller
    _calendarView.firstDate = [gregorian dateFromComponents:comps1];
    _calendarView.lastDate = [gregorian dateFromComponents:comps2];
    _calendarView.selectedDate = [NSDate date];
    _calendarView.backgroundColor = [UIColor whiteColor];
    //_calendarView.backgroundColor = kGITDefintionColorCalendarBackground;
    _calendarView.delegate = self;
    
    [self.view addSubview:_calendarView];
    
    //[_calendarView scrollToDate:[NSDate date] animated:NO]; - USE LATER TO SWTICH MONTHS
    //TODO: Add in later when I have method for switching between months
    //calendarView.tableView.scrollEnabled = NO;
    
    /*
     NOTE: I can specify rowCellClass (the row of the week) and override any of its methods here
     Can also made CalendarMonthHeaderCell class for customizing color and size
     */
    [self.formatter setDateFormat:kGITDefintionDateFormat];
    
}

//Get all events for current month through database helper
-(void)setUpTable
{
    _eventsInMonth = [[self.helper fetchEventsInMonth:_calendarView.selectedDate] mutableCopy];
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    //Register date selected
    NSLog(@"Selected the date:%@", date);
    _dateSelected = date;
    //Selection on a date pushes a new screen with events associated with the given day
    [self performSegueWithIdentifier:kGITSeguePushDayView sender:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventsInMonth count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Month Event Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    GITEvent *event = [_eventsInMonth objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
    NSString *dateString = [self.formatter stringFromDate:event.start_time];
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Get event info
        GITEvent *eventToDelete = [_eventsInMonth objectAtIndex:indexPath.row];
        BOOL inAppEvent = [eventToDelete.in_app_event boolValue];
        
        //If it's not an in app event, it's an imported event and we need to get event description and delete it from it's original calendar
        if(!inAppEvent)
        {
            _eventIdentifier = eventToDelete.event_description;
            _startOfDeletedEvent = eventToDelete.start_time;
            _endOfDeletedEvent = eventToDelete.end_time;
        }
        
        //Use database helper to delete
        BOOL eventDeleted = [self.helper deleteEventFromDatabase:eventToDelete];
        
        //If it was deleted from our app and it was imported event, also delete it from its original calendar
        if(eventDeleted)
        {
            // Update the array and table view.
            [_eventsInMonth removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            //If it was imported, get permission to delete it
            if(!inAppEvent)
            {
                //Get permission to delete it
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Permission Request"
                                                               message: @"Would you also like to delete this event from its native calendar?"
                                                              delegate: self
                                                     cancelButtonTitle:@"No"
                                                     otherButtonTitles:@"Yes",nil];
                [alert show];
            }
        }
        //Wasn't deleted from db
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Deletion Failed"
                                                           message: @"Could not delete event. Please try again."
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
}

/**
 Handles the alert asking the user's permission to delete the event from its native calendar
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Yes, delete it from native calendar
    if(buttonIndex == 1)
    {
        [self deleteFromNativeCalendarEventWithIdentifier];
    }
}

/**
 Deletes the event with the given identifier from the event's native calendar (such as iCal)
 */
-(void)deleteFromNativeCalendarEventWithIdentifier
{
    BOOL eventDeletedFromiCal = [self.syncingManager deleteiCalEventWithIdentifier:_eventIdentifier andStartTime:_startOfDeletedEvent andEndTime:_endOfDeletedEvent];
    if(!eventDeletedFromiCal)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Native Calendar Deletion Failed"
                                                       message: @"Could not delete event from its native calendar. Please go to this calendar to delete this event."
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chosenEvent = [_eventsInMonth objectAtIndex:indexPath.row];
    if([_chosenEvent.in_app_event boolValue] == YES)
    {
        [self performSegueWithIdentifier:kGITSeguePushEventDetails sender:nil];
        
    }
    else
    {
        [self performSegueWithIdentifier:kGITSegueShowEventViewController sender:nil];
    }
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Day View
    if ([[segue identifier] isEqualToString:kGITSeguePushDayView])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        
        NSArray *eventsOnDay = [self.helper fetchEventsOnDay:_dateSelected];
        vc.events = [eventsOnDay mutableCopy];
    }
    //Event Details
    else if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
    {
        GITEventDetailsViewController *vc = [segue destinationViewController];
        if ([_chosenEvent isKindOfClass:[GITAppointment class]])
        {
            vc.appointment = (GITAppointment *)_chosenEvent;
        }
        else  if ([_chosenEvent isKindOfClass:[GITTask class]])
        {
            vc.task = (GITTask *)_chosenEvent;
        }
    }
    //Event imported from iCal
    else if([[segue identifier] isEqualToString:kGITSegueShowEventViewController])
    {
        // Configure the destination event view controller
        EKEventViewController *eventViewController = (EKEventViewController *)[segue destinationViewController];
        // Set the view controller to display the selected event
        EKEvent *eventToDisplay = [self.syncingManager fetchEKEventFromEvent:_chosenEvent];
        eventViewController.event = eventToDisplay;
        eventViewController.delegate = self;
        
        // Allow event editing
        eventViewController.allowsEditing = YES;
        //TODO - Handle what happens when edited?
    }
}

- (IBAction)buttonPressedAddEvent:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Smart Schedule Task", @"Add Appointment",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Add Task
    if(buttonIndex == 0)
    {
        [self performSegueWithIdentifier:kGITSeguePushAddTask sender:self];
    }
    //Add Appointment
    else if(buttonIndex == 1)
    {
        [self performSegueWithIdentifier:kGITSeguePushAddAppointment sender:self];
    }
}

@end
