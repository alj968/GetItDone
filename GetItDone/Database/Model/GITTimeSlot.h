//
//  GITTimeSlot.h
//  GetItDone
//
//  Created by Amanda Jones on 1/8/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//TODO: Make sure when db is finalized, all the entities .h files are commented

@interface GITTimeSlot : NSManagedObject

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * time_of_day;
@property (nonatomic, retain) NSString * day_of_week;
@property (nonatomic, retain) NSManagedObject *correspondsTo;

@end
