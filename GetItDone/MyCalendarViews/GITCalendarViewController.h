//
//  ViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/1/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITCalendarView.h"
#import "GITDatebaseHelper.h"

/**
 This is the view controller & delegate for the monthly calendar view(CalendarView)
 */
@interface GITCalendarViewController : UIViewController <TSQCalendarViewDelegate>

/**
 The monthly calendar view associated with this view controller
 */
@property (strong, nonatomic) IBOutlet GITCalendarView *calendarView;

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;

@property (nonatomic, strong) NSDate *dateSelected;

@end
