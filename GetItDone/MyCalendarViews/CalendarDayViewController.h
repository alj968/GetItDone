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
@interface CalendarDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *events;
    Event *chosenEvent;
}
/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Table view for displaying the times and events
 */
@property (weak, nonatomic) IBOutlet UITableView *timeOfDayTable;

/**
 Loads events for the selected day
 */
-(void)setEventsForToday:(NSArray *)eventArray;

@end
