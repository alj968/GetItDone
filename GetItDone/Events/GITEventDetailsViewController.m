//
//  EventDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITEventDetailsViewController.h"
#import "GITAddEventViewController.h"

//TODO: Look up when to put vars in interface vs .h vs elsewhere
//TODO: Add titles to all screens
@interface GITEventDetailsViewController ()

@end

@implementation GITEventDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void)setEvent:(Event *)chosenEvent
{
    _event = chosenEvent;
}

-(void)setUp
{
    [_detailsTextView setText:[NSString stringWithFormat:@"Event Title: %@ \n Event Start Time: %@ \nEvent End Time: %@ \nEvent Duration %@ \nTask? %@",_event.title, _event.start_time, _event.end_time, _event.duration, _event.task]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEventDetails"])
    {
        // Get reference to the destination view controller
        GITAddEventViewController *vc = [segue destinationViewController];
        vc.event = _event;
        vc.editMode = true;
    }
}

@end
