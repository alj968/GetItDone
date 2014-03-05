//
//  GITTaskDetailsViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 10/29/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITTask.h"
#import "GITAppointment.h"

/**
 Allows user to view the event details of a task
 */
@interface GITEventDetailsViewController : UIViewController
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The task this screen will show the details for
 */
@property (nonatomic, strong) GITTask *task;
/**
 The appointment this screen will show the details for
 */
@property (nonatomic, strong) GITAppointment *appointment;
/**
 The event from the iphone's calendar this screen will show the details for 
 (when imported, saved in db as GITEvent)
 */
@property (nonatomic, strong) GITEvent *iCalEvent;
/**
 The textview for the title of the event
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewTitle;
/**
 The textview for the start time & end time of the event
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewTime;
/**
 The textview for the duration, category, description, priority and deadline (if existing)
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewDetails;
/**
 Sends the user to either the add event or add task screen, depending on what it is displaying the details for
 */
- (IBAction)buttonEditEvent:(id)sender;
@end
