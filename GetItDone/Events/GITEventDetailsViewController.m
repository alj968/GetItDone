//
//  EventDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITEventDetailsViewController.h"
#import "GITAddEventViewController.h"


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
    self.title = @"Event Details";

    [_detailsTextView setText:[NSString stringWithFormat:@"Event Title: %@ \nEvent Start Time: %@ \nEvent End Time: %@ \nEvent Duration %@ \nTask? %@",_event.title, _event.start_time, _event.end_time, _event.duration, _event.task]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kGITSeguePushEditEvent])
    {
        // Get reference to the destination view controller
        GITAddEventViewController *vc = [segue destinationViewController];
        vc.event = _event;
        vc.eventTitle = _event.title;
        vc.startTime = _event.start_time;
        vc.endTime = _event.end_time;
        vc.task = [_event.task stringValue];
        vc.duration = [_event.duration stringValue];
        vc.editMode = true;
    }
}

@end
