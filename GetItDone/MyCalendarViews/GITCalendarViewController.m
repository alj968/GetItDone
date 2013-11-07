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

@implementation GITCalendarViewController
//TODO: Showing dates that aren't in that month (ie going past the month but you can't click on them)
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCalendarView];
    self.title = @"Calendar";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setUpTable];
    [_tableViewEvents reloadData];
}

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
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
    _calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    
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
    
    _calendarView.backgroundColor = [UIColor colorWithRed:(198.0/255.0) green:(229.0/255.0) blue:(254.0/255.0) alpha:1];
    _calendarView.delegate = self;
    
    [self.view addSubview:_calendarView];
    
    //[_calendarView scrollToDate:[NSDate date] animated:NO]; - USE LATER TO SWTICH MONTHS
    //TODO: Add in later when I have method for switching between months
    //calendarView.tableView.scrollEnabled = NO;
    
    /*
     Note: I can specify rowCellClass (the row of the week) and override any of its methods here
     Can also made CalendarMonthHeaderCell class for customizing color and size
     */
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
    
    Event *event = [_eventsInMonth objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
    [self.formatter setDateFormat:kGITDefintionDateFormat];
    NSString *dateString = [self.formatter stringFromDate:event.start_time];
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object at the given index path.
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
        NSManagedObject *eventToDelete = [_eventsInMonth objectAtIndex:indexPath.row];
        [_context deleteObject:eventToDelete];
        
        // Commit the change.
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //If it was actually deleted from the database, delete from the array
        else {
            // Update the array and table view.
            [_eventsInMonth removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chosenEvent = [_eventsInMonth objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kGITSeguePushEventDetails sender:nil];
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushDayView])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        
        NSArray *eventsOnDay = [self.helper fetchEventsOnDay:_dateSelected];
        vc.events = [eventsOnDay mutableCopy];
    }
    else if([[segue identifier] isEqualToString:kGITSeguePushEventDetails])
    {
       GITEventDetailsViewController *vc = [segue destinationViewController];
        NSNumber *taskNumber =[_chosenEvent valueForKey:@"task"];
        //TODO: Have better way to do this!
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
