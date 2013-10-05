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
    //TODO: Make this a subview but it won't work - help!
    self.view = self.calendarView;
    
    self.title = @"Calendar";
}

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    //Register date selected
    NSLog(@"Selected the date:%@", date);
    _dateSelected = date;
    //Selection on a date pushes a new screen with events associated with the given day
    [self performSegueWithIdentifier:kGITSeguePushDayViewToCalendarMonthView sender:self];
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushDayViewToCalendarMonthView])
    {
        // Get reference to the destination view controller
        GITCalendarDayViewController *vc = [segue destinationViewController];
        
        NSArray *events = [self.helper fetchEventsOnDay:_dateSelected];
        vc.events = [events mutableCopy];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
