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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    /* NOTE: Keeping below in to remember format until I'm sure I don't want to use it
     if(self)
    {
        
    }
     */
    return self;
}

-(NSManagedObjectContext *)context
{
    if(!_context)
    {
        _context = [(AppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    }
    return _context;
}

- (Event *)event
{
    if(!self.editMode && !_event)
    {
        _event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.context];
    }
    return _event;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.editMode)
    {
        NSString *startTimeString = [NSDateFormatter localizedStringFromDate:self.event.start_time dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        
        NSString *endTimeString = [NSDateFormatter localizedStringFromDate:self.event.end_time dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        
        self.textFieldTitle.text =self.event.title;
        
        self.textFieldStartTime.text = startTimeString;
        
        self.textFieldEndTime.text = endTimeString;
        
        self.textFieldDuration.text = [self.event.duration stringValue];
        
        if([self.event.task isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            self.textFieldTask.text = @"YES";
        }
        else
        {
            self.textFieldTask.text = @"NO";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)addEventButton:(id)sender
{
    /*
     _context = [(AppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
     self.event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_context];
     */
    [self collectEventInfo];
    
    if([self saveEventSuccessful])
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
    
    /*
     //TODO: Remove this when done with this testing info
     //Print out db content
     NSError *error;
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     NSEntityDescription *entity = [NSEntityDescription
     entityForName:@"Event" inManagedObjectContext:self.context];
     [fetchRequest setEntity:entity];
     NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
     for (Event *info in fetchedObjects) {
     NSLog(@"Title: %@", info.title);
     NSLog(@"Start Time: %@", info.start_time);
     NSLog(@"End Time: %@", info.end_time);
     NSLog(@"Duration: %@", info.duration);
     NSLog(@"Task?: %@", info.task);
     */
}

-(void)collectEventInfo
{
    //Gather user's input
    NSString *titleString = self.textFieldTitle.text;
    NSString *startString = self.textFieldStartTime.text;
    NSString *endString = self.textFieldEndTime.text;
    NSString *taskString = self.textFieldTask.text;
    NSString *durationString = self.textFieldDuration.text;
    
    //TODO: Make date picker so none of the above neccessary
    //Turn start and end times to dates
    //Date format being entered - "3/15/2012 9:15 PM";
    //TODO: Make formatter into member var. if !formatter...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *startDateTime = [formatter dateFromString:startString];
    NSDate *endDateTime = [formatter dateFromString:endString];
    
    //Turn duration into a double
    double durationDouble = [durationString doubleValue];
    NSNumber *duration =[NSNumber numberWithDouble:durationDouble];
    
    //Turn task string into boolean
    BOOL taskBoolean = [taskString isEqualToString:@"YES"];
    NSNumber *task = [NSNumber numberWithBool:taskBoolean];
    
    //Set up event for entered data
    [self.event setTitle:titleString];
    [self.event setStart_time:startDateTime];
    [self.event setEnd_time:endDateTime];
    [self.event setDuration:duration];
    [self.event setTask:task];
}

-(BOOL)saveEventSuccessful
{
    //Save event
    [(AppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
    //Log error in saving data
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return false;
    }
    else
    {
        return true;
        
    }
}

@end
