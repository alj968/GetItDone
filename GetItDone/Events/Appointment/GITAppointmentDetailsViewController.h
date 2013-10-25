//
//  EventDetailsViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/4/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Appointment.h"

/**
 Allows user to view the event details of an event
 */
@interface GITAppointmentDetailsViewController : UIViewController

/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The appointment this screen will show the details for
 */
@property (nonatomic, strong) Appointment *appointment;
/**
 The textbox for the title of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 The textbox for the start date (including time) of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldStartTime;
/**
 The textbox for the end date (including time) of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndTime;
/**
 The textbox for the description of the event
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDescription;
/**
 Sets appointment to be the appointment chosen on CalendarDayView
 */
-(void)setAppointment:(Appointment *)appointment;

@end