//
//  CalendarDayViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITCalendarDayViewController.h"
#import "GITAppDelegate.h"
#import "GITEventDetailsViewController.h"

@implementation GITCalendarDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Events";
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
    GITEvent *event = [_events objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
    NSString *dateString = [self.formatter stringFromDate:event.start_time];
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chosenEvent = [_events objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kGITSeguePushEventDetails sender:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Get event info
        GITEvent *eventToDelete = [_events objectAtIndex:indexPath.row];
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
            [_events removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            //If it was imported, get permission to delete it
            if(!inAppEvent)
            {
                //Get permission to delete it
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Permission Reuqest"
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
        [self deleteFromNativeCalendarEventWithIdentifier:_eventIdentifier];
    }
}

/**
 Deletes the event with the given identifier from the event's native calendar (such as iCal)
 */
-(void)deleteFromNativeCalendarEventWithIdentifier:(NSString *)eventIdentifier
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
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
        //Otherwise, must be iCal event, which is just saved as GITevent
        else
        {
            vc.iCalEvent = _chosenEvent;
        }
    }
}


@end
