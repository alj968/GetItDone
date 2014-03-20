//
//  CalendarDayViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITCalendarDayViewController.h"
#import "GITEventDetailsViewController.h"

@implementation GITCalendarDayViewController

#pragma mark - Set up

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Events";
}

- (void)viewDidAppear:(BOOL)animated
{
    _events = [[self.helper fetchEventsOnDay:_selectedDay] mutableCopy];
    [self.tableViewTimeOfDay reloadData];
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
    [self loadiCalendarEvents];
}

// Refetches the iOS Calendar events, and reloads the table view
-(void)loadiCalendarEvents
{
    //Get all events on selected day
    NSArray *EKEvents = [self.ekEventManager fetchiCalendarEventsOnDay:_selectedDay];
    
    //Add EKEvents to existing events array
    [_events addObjectsFromArray:EKEvents];
    
    //Sort array based on start times
    _events = [self sortEventsArrayByDate:_events];
    
    //Reload table
    [self.tableViewTimeOfDay performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
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



#pragma mark - Table view delegate and datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_events count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Event Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //Check if it's an EKEvent from the event store
    if([[_events objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
    {
        EKEvent *event = [_events objectAtIndex:indexPath.row];
        cell.textLabel.text = event.title;
        NSString *dateString = [self.formatter stringFromDate:event.startDate];
        cell.detailTextLabel.text = dateString;
    }
    //If it's not, it must be a task or apointment
    else
    {
        GITEvent *event = [_events objectAtIndex:indexPath.row];
        cell.textLabel.text = event.title;
        NSString *dateString = [self.formatter stringFromDate:event.start_time];
        cell.detailTextLabel.text = dateString;
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_events objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
    {
        _chosenEKEvent = [_events objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:kGITSegueShowEventViewController sender:nil];
    }
    else
    {
        _chosenGITEvent = [_events objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:kGITSeguePushEventDetails sender:nil];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL eventDeleted = false;
        
        //Get event info
        if([[_events objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]])
        {
            //Use GITiCalendarEvent manager to delete
            EKEvent *eventToBeDeleted = [_events objectAtIndex:indexPath.row];
            [self.ekEventManager deleteiCalendarEvent:eventToBeDeleted];
            eventDeleted = YES;
        }
        else
        {
            //Use database helper to delete
            GITEvent *eventToBeDeleted = [_events objectAtIndex:indexPath.row];
            eventDeleted = [self.helper deleteEventFromDatabase:eventToBeDeleted];
        }
        
        //Update array and table view
        if(eventDeleted)
        {
            [_events removeObjectAtIndex:indexPath.row];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Event Details
    if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
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
        EKEventViewController *eventViewController = (EKEventViewController *)[segue destinationViewController];
        // Set the view controller to display the selected event
        eventViewController.event = _chosenEKEvent;
        // Allow event editing
        eventViewController.allowsEditing = YES;
    }
}

@end
