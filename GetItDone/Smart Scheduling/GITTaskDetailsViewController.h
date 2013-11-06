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
 The textview for the title of the task
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewTitle;
/**
 The textview for the start time & end time of the task
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewTime;
/**
 The textview for the duration, category, description, priority and deadline
 */
@property (strong, nonatomic) IBOutlet UITextView *textViewDetails;
/**
 Sets task to be the task chosen on CalendarDayView or CalendarView
 */
-(void)setTask:(Task *)task;
@end
