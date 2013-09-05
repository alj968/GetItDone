//
//  CalendarView.m
//  GetItDone
//
//  Created by Amanda Jones on 8/6/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "CalendarView.h"
#import "TSQCalendarView.h"
#import "TSQCalendarRowCell.h"

@implementation CalendarView

+(CalendarView *)makeCalendar
{
    CalendarView *calendarView = [[CalendarView alloc] init];
    
    //Calendar starts with the month of present date
    //TODO: Change this to a better start date
    NSDate *firstDate = [NSDate date];
    calendarView.firstDate = firstDate;
    
    calendarView.firstDate = firstDate;

    //TODO: Change this to a better end date
    NSDateComponents *comps2 = [[NSDateComponents alloc] init];
    [comps2 setDay:6];
    [comps2 setMonth:9];
    [comps2 setYear:2016];
    NSCalendar *gregorian2 = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *lastDate = [gregorian2 dateFromComponents:comps2];
    calendarView.lastDate = lastDate;
    
    /*
     Note: I can specify rowCellClass (the row of the week) and override any of its methods here
           Can also made CalendarMonthHeaderCell class for customizing color and size
     */
    //HERM: How do I create a style sheet???
    calendarView.backgroundColor = [UIColor colorWithRed:(198.0/255.0) green:(229.0/255.0) blue:(254.0/255.0) alpha:1];

    return calendarView;    
}

@end
