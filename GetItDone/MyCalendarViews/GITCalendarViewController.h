//
//  ViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/1/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatabaseHelper.h"
#import "TSQCalendarView.h"
#import "GITSyncingManager.h"

/**
 This is the view controller & delegate for the monthly calendar view(CalendarView)
 */
@interface GITCalendarViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

/**
 Formats dates. E.g. "Sept 6, 2013 1:00 PM"
 */
@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The class that handles all interactions with EKEvents from iCal
 */
@property (nonatomic, strong) GITSyncingManager *syncingManager;
/**
 The Times Square montly calendar view
 */
@property (nonatomic, strong) TSQCalendarView *calendarView;
/**
 This method called when the user presses the button to add an event
 */
- (IBAction)buttonPressedAddEvent:(id)sender;
/**
 The date selected in the calendar
 */
@property (nonatomic, strong) NSDate *dateSelected;
/**
 The events from the database for the selected day's month
 */
@property (nonatomic, strong) NSMutableArray *eventsInMonth;
/**
 The table holding all events in the chosen month
 */
@property (strong, nonatomic) IBOutlet UITableView *tableViewEvents;
/**
 The event for which the user would like to view the details
 */
@property (nonatomic, strong) GITEvent *chosenEvent;

@end
