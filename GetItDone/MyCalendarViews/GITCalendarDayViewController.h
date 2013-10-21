//
//  CalendarDayViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

/**
 This is the day view for the calendar. It displays times and, if in existence, their corresponding events
 */
@interface GITCalendarDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;

/**
 The events from the database for the selected day
 */
@property (nonatomic, strong) NSMutableArray *events;

/**
 The event for which the user would like to view the details
 */
@property (nonatomic, strong) Event *chosenEvent;

/**
 Table view for displaying the times and events
 */
@property (weak, nonatomic) IBOutlet UITableView *tableViewTimeOfDay;

@end
