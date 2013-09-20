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

@implementation GITCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void)setUp
{
    self.calendarView = [GITCalendarView makeCalendar];
    self.calendarView.delegate = self;
    self.view = self.calendarView;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    //Register date selected
    NSLog(@"Selected the date:%@", date);
    _dateSelected = date;
    //Selection on a date pushes a new screen with events associated with the given day
    [self performSegueWithIdentifier:@"MonthToDayView" sender:self];
}

//TODO: Clean up, seperate into separate methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MonthToDayView"])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
        
        //Form fetch request for event entity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        
        //Get the date selected, so it will only fetch events on that day
        //Start of range will be date selected at 12:00 am
        NSDate *dateSelected = _dateSelected;
        //Times square shows dateSelected as having time 4:00 am, must subtract 4 hours
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:@"gregorian"];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setHour:-4];
        dateSelected = [cal dateByAddingComponents:comps toDate:dateSelected  options:0];
        //End of date range will be 12:00 am of next day
        NSDate *endOfDateSelected = [_dateSelected dateByAddingTimeInterval:(24*60*60)];

        //Form predicate to only get events in the specified date range
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"start_time <= %@ && start_time >= %@", endOfDateSelected, dateSelected];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"start_time" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        NSError *error;
        
        NSArray *events = [_context executeFetchRequest:fetchRequest error:&error];

        vc.events = [events mutableCopy];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
