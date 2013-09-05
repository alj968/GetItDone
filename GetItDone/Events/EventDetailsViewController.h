//
//  EventDetailsViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventDetailsViewController : UIViewController

/**
 The event this screen will show the details for
 */
@property (nonatomic, strong) Event *event;
/**
 The text view that displays the details of the event
 */
@property (strong, nonatomic) IBOutlet UITextView *detailsTextView;

/**
 Sets event to be the event chosen on CalendarDayView
 */
-(void)setEvent:(Event *)chosenEvent;
/**
 Allows user to edit event details
 */
- (IBAction)editEventButton:(id)sender;

@end
