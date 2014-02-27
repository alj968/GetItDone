//
//  GITTimeSlotManager+Private.h
//  GetItDone
//
//  Created by Amanda Jones on 2/21/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITTimeSlotManager.h"

@interface GITTimeSlotManager (Private)

-(int)getChangeByNumberForAction:(NSString *)action;

-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSLot AtSameTimeAs:(GITTimeSlot *)secondTimeSlot;

- (BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot OnSameDayAs:(GITTimeSlot *)secondTimeSlot;

-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot InSameDayGroupAs:(GITTimeSlot *)secondTimeSlot;

-(BOOL)isTimeSlot:(GITTimeSlot *)firstTimeSlot InSameTimeGroupAs:(GITTimeSlot *)secondTimeSlot;


@end
