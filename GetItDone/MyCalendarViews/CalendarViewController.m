//
//  ViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/1/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "CalendarViewController.h"
#import "TSQCalendarView.h"
#import "CalendarDayViewController.h"
#import "AppDelegate.h"

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void)setUp
{
    self.calendarView = [CalendarView makeCalendar];
 
    self.calendarView.delegate = self;
    self.view = self.calendarView;
    
    //Can set up new view controller for calendar if I wanted to
    /*
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = self.calendarView;
    [self.nasvigationController pushViewController:vc animated:true];
     */
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    //Have this in place so I know app knows when I make a selection
    NSLog(@"Selected the date:%@", date);
    //Get all evenst for the day
    
    //Selection on a date pushes a new screen with times associated with the given day
    [self performSegueWithIdentifier:@"MonthToDayView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MonthToDayView"])
    {
        // Get reference to the destination view controller
        CalendarDayViewController *vc = [segue destinationViewController];
        _context = [(AppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Event" inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *events = [_context executeFetchRequest:fetchRequest error:&error];
        // Pass any objects to the view controller here, like...
        [vc setEventsForToday:events];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
