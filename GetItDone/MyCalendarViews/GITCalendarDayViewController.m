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

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Use database helper to delete
        BOOL eventDeleted = [self.helper deleteEventFromDatabase:[_events objectAtIndex:indexPath.row]];
        //If it was actually deleted from the database, delete from the array
        if(eventDeleted)
        {
            // Update the array and table view.
            [_events removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        }
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
    }
}


@end
