//
//  GITTimeSlotManager.h
//  GetItDone
//
//  Created by Amanda Jones on 1/24/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITTimeSlot.h"
#import "GITDatebaseHelper.h"

@interface GITTimeSlotManager : NSObject

/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;
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
 @param action The user action (accept/reject/do/postpone)
 */
-(void)adjustTimeSlotsForDate:(NSDate *)startingDate forUserAction:(NSString *)action;



@end