//
//  EventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "AddEventViewController.h"
#import "Event.h"
#import "CalendarViewController.h"

@implementation AddEventViewController

-(id)initWithEvent:(Event *)event
{
    if(!event)
    {
        _event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_context];
    }
    else
    {
        _event = event;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return [self initWithEvent:_event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //IN PROGRESS
    if(_event)
    {
        NSString *startTimeString = [NSDateFormatter localizedStringFromDate:_event.start_time dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        
        NSString *endTimeString = [NSDateFormatter localizedStringFromDate:_event.end_time dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];

        _titleTextField.text = _event.title;
        _startTextField.text = startTimeString;
        _endTextField.text = endTimeString;
        _durationTextField.text = [_event.duration stringValue];
        _taskTextField.text = [_event.task stringValue];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)addEventButton:(id)sender {
    //NOTE: This will all be simpler when I have pickers in
    //Gather user's input
    NSString *titleString = _titleTextField.text;
    NSString *startString = _startTextField.text;
    NSString *endString = _endTextField.text;
    NSString *taskString = _taskTextField.text;
    NSString *durationString = _durationTextField.text;
    
    //Turn start and end times to dates
    //Date format being entered - "3/15/2012 9:15 PM";
    //TODO: Make formatter into member var. if !formatter...
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *startDateTime = [formatter dateFromString:startString];
    NSDate *endDateTime = [formatter dateFromString:endString];
    
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
    
    //Set up event for entered data
    _event.title = titleString;
    _event.start_time = startDateTime;
    _event.end_time = endDateTime;
    _event.duration = duration;
    _event.task = task;
    
    //Save event
    [(AppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    //Log error in saving data
    NSError *error;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    //If saved successfully, pop back to calendar month view
    else
    {
        [self.navigationController popToRootViewControllerAnimated:true];
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
