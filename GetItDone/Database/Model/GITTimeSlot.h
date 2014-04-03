//
//  GITTimeSlot.h
//  GetItDone
//
//  Created by Amanda Jones on 4/2/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GITCategory;

/**
 The model class for the GITTimeSlot entity. Each category has 168 of these to make an informal "time slot table", corresponding to each hour of each day of the week.
 */
@interface GITTimeSlot : NSManagedObject

/**
 The day of the week (Sunday, Monday, etc). Required.
 */
@property (nonatomic, retain) NSString * day_of_week;
/**
 The hour of the day, out of 24 hours. Required.
 */
@property (nonatomic, retain) NSNumber * time_of_day;
/**
 The weight of that time slot. Required. Starts at 0 and decreases/increases with each user action
 */
@property (nonatomic, retain) NSNumber * weight;
/**
 The category the time slot corresponds to. Required.
 */
@property (nonatomic, retain) GITCategory *correspondsTo;

@end
