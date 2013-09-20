//
//  EventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITAddEventViewController.h"
#import "Event.h"
#import "GITCalendarViewController.h"
#import "GITSelectDate.h"

@implementation GITAddEventViewController

-(NSManagedObjectContext *)context
{
    if(!_context)
    {
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
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

-(NSDateFormatter *)formatter
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MMM d, y h:mm a"];
    }
    return _formatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    //If coming in from event details, populate textfields with info
    if(self.editMode)
    {
        _eventTitle = self.event.title;
        _startTime = self.event.start_time;
        _endTime = self.event.end_time;
        _duration = self.event.duration;
        _task = self.event.task;
    }
        
    //If any of the text fields are filled in before going to select date screen,
    //make sure that when you come back to this screen, that prevoiusly selected
    //data will be in the textfields
    if(_eventTitle)
    {
        self.textFieldTitle.text = _eventTitle;
    }
    if(_startTime)
    {
        self.textFieldStartTime.text = [self.formatter stringFromDate:_startTime];
    }
    if(_endTime)
    {
        self.textFieldEndTime.text = [self.formatter stringFromDate:_endTime];
    }
    if(_duration)
    {
        self.textFieldDuration.text = [_duration stringValue];
    }
    if(_task)
    {
        self.textFieldTask.text = [self taskNumberToString:_task];
    }
}

- (IBAction)addEventButton:(id)sender
{
    [self setEventInfo];
    
    if([self saveEventSuccessful])
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
}

-(void)setEventInfo
{
    //Last edited field, e.g one that has not been saved, is
    //either going to be title, duration or task
    if(_lastEditedField == _textFieldTitle)
    {
        _eventTitle = _lastEditedField.text;
    }
    else if(_lastEditedField == _textFieldDuration)
    {
        _duration = [self durationStringToNumber:(_lastEditedField.text)];
    }
    else if(_lastEditedField == _textFieldTask)
    {
        _task = [self taskStringToNumber:(_lastEditedField.text)];
    }
    
    //Set up event for entered data
    [self.event setTitle:_eventTitle];
    [self.event setStart_time:_startTime];
    [self.event setEnd_time:_endTime];
    [self.event setDuration:_duration];
    [self.event setTask:_task];

}

-(BOOL)saveEventSuccessful
{
    //Save event
    [(GITAppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _textFieldTitle)
    {
        _eventTitle = textField.text;
    }
     else if(textField == _textFieldDuration)
     {
         _duration = [self durationStringToNumber:(self.textFieldDuration.text)];
     }
     else if(textField == _textFieldTask)
     {
         _task = [self taskStringToNumber:(self.textFieldTask.text)];
     }
}

- (NSNumber *)durationStringToNumber:(NSString *) durationString
{
    return [NSNumber numberWithDouble:[durationString doubleValue]];
}

- (NSNumber *)taskStringToNumber:(NSString *)taskString
{
    BOOL taskBoolean = [taskString isEqualToString:@"YES"];
    return [NSNumber numberWithBool:taskBoolean];
}

-(NSString *)taskNumberToString:(NSNumber *)taskNumber
{
    if([taskNumber isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        return @"YES";
    }
    else
    {
        return @"NO";
    }
}

//Keep track of last edited text field because this one may not have
//been saved, because textFieldDidEndEditing may have never been called
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _lastEditedField = textField;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toSelectTime"])
    {
        // Get reference to the destination view controller
        GITSelectDate *vc = [segue destinationViewController];
        vc.addVC = self;
    }
}

@end
