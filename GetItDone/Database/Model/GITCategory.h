//
//  GITCategory.h
//  GetItDone
//
//  Created by Amanda Jones on 1/8/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GITTimeSlot;

@interface GITCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) GITTimeSlot *correspondsTo;

@end
