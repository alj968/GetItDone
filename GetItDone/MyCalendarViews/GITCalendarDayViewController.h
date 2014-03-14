//
//  CalendarDayViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITEvent.h"
#import "GITDatabaseHelper.h"
#import "GITEKEventManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

/**
 This is the day view for the calendar. It displays times and, if in existence, their corresponding events
 */
@interface GITCalendarDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The iCalendar's event store
 */
@property (nonatomic, strong) EKEventStore *eventStore;
/**
 The entity manager for EKEvents
 */
@property (nonatomic, strong) GITEKEventManager *ekEventManager;
/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The events from the database for the selected day
 */
@property (nonatomic, strong) NSMutableArray *events;
/**
 The GITEvent for which the user would like to view the details
 */
@property (nonatomic, strong) GITEvent *chosenGITEvent;
/**
 The EKEvnet for which the user would like to view the details
 */
@property (nonatomic, strong) EKEvent *chosenEKEvent;
/**
 Table view for displaying the times and events
 */
@property (weak, nonatomic) IBOutlet UITableView *tableViewTimeOfDay;


@end
