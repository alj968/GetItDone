//
//  SetUpScheduleViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "SetUpScheduleViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "NSDate+Utilities.h"

@implementation SetUpScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Inialize data base with events
- (IBAction)setUpEvents:(id)sender
{
    _context = [(AppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    
    //Set up event for dentist appointment
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_context];
    NSDate *dentistStartDate = [NSDate makeDateWithYear:2013 month:9 day:6 hour:11 minutes:0 seconds:0];
    NSDate *dentistEndDate = [NSDate dateWithTimeInterval:(60*60*2) sinceDate:dentistStartDate];
    NSNumber *duration = [[NSNumber alloc] initWithInt:2];
    
    event.title = @"Dentist";
    event.start_time = dentistStartDate;
    event.end_time = dentistEndDate;
    event.duration = duration;
    event.task = [NSNumber numberWithBool:NO];
    
    //Is below line needed???
    [(AppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    //Log error in saving data
    NSError *error;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    //Print out db content
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    for (Event *info in fetchedObjects) {
        NSLog(@"Title: %@", info.title);
        NSLog(@"Start Time: %@", info.start_time);
        NSLog(@"End Time: %@", info.end_time);
        NSLog(@"Duration: %@", info.duration);
        NSLog(@"Task?: %@", info.task);
    }
}

- (NSDate *)makeAllDayDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    return [NSDate makeDateWithYear:year month:month day:day hour:0 minutes:0 seconds:0];
}
//!!Make this method in a category on nsdate

@end
