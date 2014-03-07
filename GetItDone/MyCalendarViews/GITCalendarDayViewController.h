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
#import "GITSyncingManager.h"

/**
 This is the day view for the calendar. It displays times and, if in existence, their corresponding events
 */
@interface GITCalendarDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The class that handles all interactions with EKEvents from iCal
 */
@property (nonatomic, strong) GITSyncingManager *syncingManager;
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
@property (nonatomic, strong) GITEvent *chosenEvent;
/**
 Table view for displaying the times and events
 */
@property (weak, nonatomic) IBOutlet UITableView *tableViewTimeOfDay;
/**
 The string identifying the imported event (it's identifier in its native calendar)
 */
@property (nonatomic, strong) NSString *eventIdentifier;
/**
 The start time of the event to be deleted
 */
@property (nonatomic, strong) NSDate *startOfDeletedEvent;
/**
 The end time of the event to be deleted
 */
@property (nonatomic, strong) NSDate *endOfDeletedEvent;


@end
