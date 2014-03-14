//
//  GITEventViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 3/12/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITEventViewController.h"

@implementation GITEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*
  Called when user done on EKEventEditViewController
 */
-(void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    //Dismiss EKEventEditViewController
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    //Let GITCalendarViewController view know it needs to refetch iOS Calendar events
    GITCalendarViewController *calendarVC = [[GITCalendarViewController alloc] init];
    //TODO - change this to call load method (needs to go in . h file first of calendar vc)[calendarVC sync];
}


@end
