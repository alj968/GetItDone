//
//  GITTimeSlotManager.h
//  GetItDone
//
//  Created by Amanda Jones on 1/24/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITTimeSlot.h"
#import "GITDatabaseHelper.h"

@interface GITTimeSlotManager : NSObject

/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The time slot corresponding to the start time upon which a user action was taken
 */
@property (nonatomic, strong) GITTimeSlot *timeSlot;

/**
 Handles time slot changes for when a user action is taken.
 Possible user actions: accept/reject smart scheduling suggestion; do/postpone task
 Contains logic for how much to alter time slot depending on user action,
 and adjusts the time slots accordingly
 @param startingDate The task start time upon which the user action was taken
 @param categoryTitle The task's category title (so only time slots within this category are changed)
 @param action The user action (accept/reject/do/postpone)
 */
-(void)adjustTimeSlotsForDate:(NSDate *)startingDate duration:(NSNumber *)duration categoryTitle:(NSString *)categoryTitle userAction:(NSString *)action;

@end
