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
#import "NSDate+Utilities.h"
#import "GITTSQCalendarRowCell.h"

@implementation GITCalendarViewController
#pragma mark - Set up
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up nav bar to show calendar view on top of it
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    [self setUpCalendarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setUpEventsTable];
    [self checkEventStoreAccessForCalendar];
    // Scroll to third row so that multiple filled in rows are immediately visible
    /*
    if(_eventsInMonth.count > 3)
    {
        [self.tableViewEvents scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }*/
    
}

- (void)setUpEventsTable
{
    NSDate *monthDate = [NSDate date];
    if(self.calendarView.selectedDate)
    {
        monthDate = self.calendarView.selectedDate;
    }
    _eventsInMonth = [[self.helper fetchEventsInMonth:monthDate] mutableCopy];
    [self.tableViewEvents reloadData];
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
    _calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 415)];
    
    // Set to my custom row cell class
    _calendarView.rowCellClass = [GITTSQCalendarRowCell class];
    
    // Set first and last date
    _calendarView.firstDate = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 365 * 1];
    _calendarView.lastDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365 * 5];
    
    // Formatting
    _calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    _calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    _calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    //_calendarView.selectedDate = [NSDate date];
    _calendarView.delegate = self;
    
    [self.view addSubview:_calendarView];
    
    [self.formatter setDateFormat:kGITDefintionDateFormat];
}

- (void)viewDidLayoutSubviews;
{
    // Set the calendar view to show today date on start
    [self.calendarView scrollToDate:[NSDate date] animated:NO];
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
             // Display alert
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not allowing calendar access prevents this app from syncing with your iOS Calendar. If you change your mind, go to Settings - General - Reset - Reset Location & Privacy and then reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
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

// Call loadiCalendarEvents
- (void)storeChanged:(NSNotification *)notification
{
    [self setUpEventsTable];
    [self loadiCalendarEvents];
}

// Refetches the iOS Calendar events, and reloads the table view
-(void)loadiCalendarEvents
{
    //Get all events starting today until end of month
    NSDate *startDate;
    if(_dateSelected)
    {
        startDate = _dateSelected;
    }
    else
    {
        startDate = [NSDate date];
    }
    NSDate *endDate = [self lastDayOfMonthOfDate:startDate];
    NSArray *EKEvents = [self.ekEventManager fetchiCalendarEventsFrom:startDate until:endDate];
    
    //Add EKEvents to existing events array
    [_eventsInMonth addObjectsFromArray:EKEvents];
    
    //Sort array based on start times
    _eventsInMonth = [self sortEventsArrayByDate:_eventsInMonth];
    
    //Reload table
    [self.tableViewEvents performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

-(NSMutableArray *)sortEventsArrayByDate:(NSMutableArray *)eventsArray
{
    NSArray *sortedEvents = [eventsArray sortedArrayUsingComparator:^NSComparisonResult(id event1, id event2)
                             {
                                 NSDate *date1;
                                 NSDate *date2;
                                 
                                 //Get first date
                                 if([event1 isKindOfClass:[GITEvent class]])
                                 {
                                     GITEvent *event = (GITEvent *)event1;
                                     date1 = event.start_time;
                                 }
                                 else if([event1 isKindOfClass:[EKEvent class]])
                                 {
                                     EKEvent *event = (EKEvent *)event1;
                                     date1 = event.startDate;
                                 }
                                 
                                 //Get the second date
                                 if([event2 isKindOfClass:[GITEvent class]])
                                 {
                                     GITEvent *event = (GITEvent *)event2;
                                     date2 = event.start_time;
                                 }
                                 else if([event2 isKindOfClass:[EKEvent class]])
                                 {
                                     EKEvent *event = (EKEvent *)event2;
                                     date2 = event.startDate;
                                 }
                                 
                                 //Compare
                                 return [date1 compare:date2];
                             }];
    return [sortedEvents mutableCopy];
}

// Forms a date that is the last day of the month
-(NSDate *)lastDayOfMonthOfDate:(NSDate *)date
{
    //Get month and year from passed in date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
    int month = [components month];
    int year = [components year];
    
    //Make dates for last day of this month
    return [NSDate dateWithYear:year month:month weekday:0 day:31 hour:0 minutes:0 seconds:0];
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
    
    //Refresh table
    _eventsInMonth = [[self.helper fetchEventsInMonth:date] mutableCopy];
    [self.tableViewEvents reloadData];
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Day View
    if ([[segue identifier] isEqualToString:kGITSeguePushDayView])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        vc.selectedDay = _dateSelected;
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
        EKEventViewController *eventViewControlller = [segue destinationViewController];
        // Set the view controller to display the selected event
        eventViewControlller.event = _chosenEKEvent;
        // Allow event editing
        eventViewControlller.allowsEditing = YES;
        self.navigationController.navigationBar.translucent = NO;
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
