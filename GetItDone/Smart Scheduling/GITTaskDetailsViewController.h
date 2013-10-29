//
//  GITTaskDetailsViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 10/29/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

/**
 Allows user to view the event details of a task
 */
@interface GITTaskDetailsViewController : UIViewController
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The task this screen will show the details for
 */
@property (nonatomic, strong) Task *task;
/**
 The textbox for the title of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
/**
 Start time of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldStartTime;
/**
 End time of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndTime;
/**
 The textbox for the duration of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDuration;
/**
 The textbox for the category of the task
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldCategory;
/**
 The textbox for the  description of the task
 */
@property (strong, nonatomic) IBOutlet
UITextField *textFieldDescription;
/**
 The textbox for the task's numeric priority
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldPriority;
/**
 The textbox for the deadline - date before which task must be completed
 */
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeadline;
/**
 Sets task to be the task chosen on CalendarDayView or CalendarView
 */
-(void)setTask:(Task *)task;
@end
