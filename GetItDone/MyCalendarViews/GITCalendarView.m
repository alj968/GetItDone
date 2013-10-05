//
//  CalendarView.m
//  GetItDone
//
//  Created by Amanda Jones on 8/6/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITCalendarView.h"
#import "TSQCalendarView.h"
#import "TSQCalendarRowCell.h"

@implementation GITCalendarView

+(GITCalendarView *)makeCalendar
{
    GITCalendarView *calendarView = [[GITCalendarView alloc] init];
    
    //Calendar starts at Sept of 2013
    //TODO: Finalize what these dates should be
    //TODO: Make sure that regardless of start date, my app always displays current month
    NSDateComponents *comps1 = [[NSDateComponents alloc] init];
    [comps1 setDay:6];
    [comps1 setMonth:9];
    [comps1 setYear:2013];
    
    NSDateComponents *comps2 = [[NSDateComponents alloc] init];
    [comps2 setDay:6];
    [comps2 setMonth:9];
    [comps2 setYear:2050];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar];
    
    calendarView.firstDate = [gregorian dateFromComponents:comps1];
    calendarView.lastDate = [gregorian dateFromComponents:comps2];
    
    /*
     Note: I can specify rowCellClass (the row of the week) and override any of its methods here
           Can also made CalendarMonthHeaderCell class for customizing color and size
     */
    calendarView.backgroundColor = [UIColor colorWithRed:(198.0/255.0) green:(229.0/255.0) blue:(254.0/255.0) alpha:1];

    return calendarView;    
}

@end
