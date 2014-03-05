//
//  GITTimeSlot.h
//  GetItDone
//
//  Created by Amanda Jones on 3/5/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GITCategory;

@interface GITTimeSlot : NSManagedObject

@property (nonatomic, retain) NSString * day_of_week;
@property (nonatomic, retain) NSNumber * time_of_day;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) GITCategory *correspondsTo;

@end
