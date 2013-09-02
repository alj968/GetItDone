//
//  ViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/1/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 This is the view controller & delegate for the monthly calendar view(CalendarView)
 */
#import <UIKit/UIKit.h>
#import "CalendarView.h"

@interface CalendarViewController : UIViewController <TSQCalendarViewDelegate>

/**
 The monthly calendar view associated with this view controller
 */
@property (strong, nonatomic) IBOutlet CalendarView *calendarView;

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
