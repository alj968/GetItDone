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
    Event *event = [_events objectAtIndex:indexPath.row];
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
        
        // Delete the managed object at the given index path.
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
        NSManagedObject *eventToDelete = [_events objectAtIndex:indexPath.row];
        [_context deleteObject:eventToDelete];
        
        // Commit the change.
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //If it was actually deleted from the database, delete from the array
        else {
            // Update the array and table view.
            [_events removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
    {
        GITEventDetailsViewController *vc = [segue destinationViewController];
        NSNumber *taskNumber =[_chosenEvent valueForKey:@"task"];
        if([taskNumber intValue] == 0)
        {
            [vc setAppointment:_chosenEvent];
        }
        else
        {
            [vc setTask:_chosenEvent];
        }
    }
}

@end
