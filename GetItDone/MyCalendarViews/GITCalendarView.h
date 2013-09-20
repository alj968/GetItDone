//
//  CalendarView.h
//  GetItDone
//
//  Created by Amanda Jones on 8/6/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 The monthly calendar view, which inherits from TSQCalendarView
 */
#import <UIKit/UIKit.h>
#import "TSQCalendarView.h"

@interface GITCalendarView : TSQCalendarView <TSQCalendarViewDelegate>

/**
 Inializes a calendar view with start & end date, and customizes calendar
 @reutrn calendarview The TSQCalendarView
 */
+(GITCalendarView *)makeCalendar;

@end
