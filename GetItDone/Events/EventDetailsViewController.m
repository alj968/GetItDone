//
//  EventDetailsViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AddEventViewController.h"

//TODO: Look up when to put vars in interface vs .h vs elsewhere
//TODO: Add titles to all screens
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

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
    [self setUp];
	// Do any additional setup after loading the view.
}

-(void)setEvent:(Event *)chosenEvent
{
    _event = chosenEvent;
}

-(void)setUp
{
    [_detailsTextView setText:[NSString stringWithFormat:@"Event Title: %@ \nEvent Start Time: %@ \nEvent End Time: %@ \nEvent Duration %@ \nTask? %@",_event.title, _event.start_time, _event.end_time, _event.duration, _event.task]];
    
}

- (IBAction)editEventButton:(id)sender {
    [self performSegueWithIdentifier:@"editEventDetails" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEventDetails"])
    {
        // Get reference to the destination view controller
        AddEventViewController *vc = [segue destinationViewController];
        vc.event = _event;
        vc.editMode = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
