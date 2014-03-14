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
#import "GITEventDetailsViewController.h"
#import "GITAddTaskViewController.h"
#import "GITAddAppointmentViewController.h"

@implementation GITCalendarViewController
//TODO - bug. app crashes if while on this screen, you go to settings and reset privacy settings
#pragma mark - Set up
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCalendarView];
    self.title = @"Calendar";
}

- (void)viewDidAppear:(BOOL)animated
{
    _eventsInMonth = [[self.helper fetchEventsInMonth:[NSDate date]] mutableCopy];
    [self.tableViewEvents reloadData];
    [self checkEventStoreAccessForCalendar];
}

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

- (GITEKEventManager *)ekEventManager
{
    if(!_ekEventManager)
    {
        _ekEventManager = [[GITEKEventManager alloc] init];
    }
    return _ekEventManager;
}

- (EKEventStore *)eventStore
{
    if(!_eventStore)
    {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
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

#pragma mark - TSQCalendarView methods
// Sets start & end dates for TSQCalendar, and formats the calendar view
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

#pragma mark - iOS Calendar Methods

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [self accessDeniedForCalendar];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             [self accessGrantedForCalendar];
         }
         else
         {
             [self accessDeniedForCalendar];
         }
     }];
}

// Call loadiCalendarEvents and register for notifications when event store changes
-(void)accessGrantedForCalendar
{
    [self loadiCalendarEvents];
    
    //Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:self.eventStore];
}

// Display alert
//TODO - this gets called but doesn't show the first time you say no to permission?
-(void)accessDeniedForCalendar
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not allowing calendar access prevents this app from syncing with your iOS Calendar. If you change your mind, go to Settings - General - Reset - Reset Location & Privacy and then reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

//TODO: Check that this is being called every time it should be (called when you edit event :) )
// Call loadiCalendarEvents
- (void)storeChanged:(NSNotification *)notification
{
    [self loadiCalendarEvents];
}

// Refetches the iOS Calendar events, and reloads the table view
-(void)loadiCalendarEvents
{
    //Add EKEvents to existing events array
    NSArray *EKEvents = [self.ekEventManager fetchiCalendarEvents];
    [_eventsInMonth addObjectsFromArray:EKEvents];
    //TODO - Sort the array by time using custom comparator/selector
    //Reload table
    [self.tableViewEvents performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark - Table view delegate and datasource methods

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
    //Check if it's an EKEvent from the event store
    if([[_eventsInMonth objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
    {
        EKEvent *event = [_eventsInMonth objectAtIndex:indexPath.row];
        cell.textLabel.text = event.title;
        NSString *dateString = [self.formatter stringFromDate:event.startDate];
        cell.detailTextLabel.text = dateString;
    }
    //If it's not, it must be a task or apointment
    else
    {
        GITEvent *event = [_eventsInMonth objectAtIndex:indexPath.row];
        cell.textLabel.text = event.title;
        NSString *dateString = [self.formatter stringFromDate:event.start_time];
        cell.detailTextLabel.text = dateString;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOOL eventDeleted = false;
        
        //Get event info
        if([[_eventsInMonth objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
        {
            //Use GITiCalendarEvent manager to delete
            EKEvent *eventToBeDeleted = [_eventsInMonth objectAtIndex:indexPath.row];
            [self.ekEventManager deleteiCalendarEvent:eventToBeDeleted];
            //TODO - pass in error so I can actualliy know if it was deleted or not?
            eventDeleted = YES;
        }
        else
        {
            //Use database helper to delete
            GITEvent *eventToBeDeleted = [_eventsInMonth objectAtIndex:indexPath.row];
            eventDeleted = [self.helper deleteEventFromDatabase:eventToBeDeleted];
        }
        
        //Update array and table view
        if(eventDeleted)
        {
            [_eventsInMonth removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
        }
        //Display error that event could not be deleted
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_eventsInMonth objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
    {
        _chosenEKEvent = [_eventsInMonth objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:kGITSegueShowEventViewController sender:nil];
    }
    else
    {
        _chosenGITEvent = [_eventsInMonth objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:kGITSeguePushEventDetails sender:nil];
    }
}

#pragma mark - Navigation methods

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    //Register date selected
    _dateSelected = date;
    //Selection on a date pushes a new screen with events associated with the given day
    [self performSegueWithIdentifier:kGITSeguePushDayView sender:self];
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Day View
    if ([[segue identifier] isEqualToString:kGITSeguePushDayView])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        //todo - going to need this to also get ios calendar events ont that day!
        NSArray *eventsOnDay = [self.helper fetchEventsOnDay:_dateSelected];
        vc.events = [eventsOnDay mutableCopy];
    }
    //Event Details
    else if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
    {
        GITEventDetailsViewController *vc = [segue destinationViewController];
        if ([_chosenGITEvent isKindOfClass:[GITAppointment class]])
        {
            vc.appointment = (GITAppointment *)_chosenGITEvent;
        }
        else  if ([_chosenGITEvent isKindOfClass:[GITTask class]])
        {
            vc.task = (GITTask *)_chosenGITEvent;
        }
    }
    //Event imported from iOS Calendar
    else if([[segue identifier] isEqualToString:kGITSegueShowEventViewController])
    {
        // Configure the destination event view controller
        GITEventViewController *eventViewController = (GITEventViewController *)[segue destinationViewController];
        // Set the view controller to display the selected event
        eventViewController.event = _chosenEKEvent;
        // Allow event editing
        eventViewController.allowsEditing = YES;
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
