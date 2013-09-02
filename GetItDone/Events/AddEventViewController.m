//
//  AddEventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "AddEventViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "CalendarViewController.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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


- (IBAction)addEventButton:(id)sender {
    //Get all input
    NSString *titleString = _titleTextBox.text;
    NSString *startString = _startTimeTextBox.text;
    NSString *endString = _endTimeTextBox.text;
    NSString *taskString = _taskTextBox.text;
    NSString *durationString = _durationTextBox.text;
    
    //Turn start and end times to dates
    
    //NSString *str =@"3/15/2012 9:15 PM";
    //Make formatter into member var!!! if !formatter...
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *startDateTime = [formatter dateFromString:startString];
    NSDate *endDateTime = [formatter dateFromString:endString];
    
    //NSLog(@"Start: %@ End: %@",startDateTime, endDateTime);
    
    //Turn duration into a double
    double durationDouble = [durationString doubleValue];
    NSNumber *duration =[NSNumber numberWithDouble:durationDouble];
    
    //Turn task string into boolean
    BOOL taskBoolean;
    if([taskString isEqualToString:@"YES"])
    {
        taskBoolean = YES;
    }
    else
    {
        taskBoolean = NO;
    }
    NSNumber *task = [NSNumber numberWithBool:taskBoolean];
    
    //Add this event to the db
    _context = [(AppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    
    //Set up event for dentist appointment
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_context];
    
    event.title = titleString;
    event.start_time = startDateTime;
    event.end_time = endDateTime;
    event.duration = duration;
    event.task = task;
    
    //Is below line needed???
    [(AppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    //Log error in saving data
    NSError *error;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else
    {
        [self performSegueWithIdentifier: @"eventAddedSegue" sender: self];
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
@end
