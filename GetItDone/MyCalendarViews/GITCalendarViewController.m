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
    [self setUpCalendarView];

    self.title = @"Calendar";
}

-(void)setUpCalendarView
{
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        
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
    calendarView.firstDate = [gregorian dateFromComponents:comps1];
    calendarView.lastDate = [gregorian dateFromComponents:comps2];
    
    calendarView.backgroundColor = [UIColor colorWithRed:(198.0/255.0) green:(229.0/255.0) blue:(254.0/255.0) alpha:1];
    //TODO: Add in later when I have method for switching between months
    //calendarView.tableView.scrollEnabled = NO;

    calendarView.delegate = self;

    [self.view addSubview:calendarView];
    
    /*
     Note: I can specify rowCellClass (the row of the week) and override any of its methods here
     Can also made CalendarMonthHeaderCell class for customizing color and size
     */
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
    [self performSegueWithIdentifier:kGITSeguePushDayView sender:self];
}

//Uses the database helper to get the events on for the selected day
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushDayView])
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
