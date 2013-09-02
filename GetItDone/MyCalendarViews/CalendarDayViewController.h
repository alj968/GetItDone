//
//  CalendarDayViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 This is the day view for the calendar. It displays times and, if in existence, their corresponding events
 */
#import <UIKit/UIKit.h>
#import "Event.h"

@interface CalendarDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *times;
    NSArray *events;
}
/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

//Herm - why make something a property rather than declaring it in the interface?
/**
 The events stored in the datebases
 */
//@property (nonatomic, strong) NSArray *events;

/**
 Table view for displaying the times and events
 */
@property (weak, nonatomic) IBOutlet UITableView *timeOfDayTable;

-(void)setEventsForToday:(NSArray *)eventArray;

@end
