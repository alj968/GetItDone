//
//  GITCategory.h
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GITTask, GITTimeSlot;

@interface GITCategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) GITTimeSlot *correspondsTo;
@property (nonatomic, retain) NSSet *contains;
@end

@interface GITCategory (CoreDataGeneratedAccessors)

- (void)addContainsObject:(GITTask *)value;
- (void)removeContainsObject:(GITTask *)value;
- (void)addContains:(NSSet *)values;
- (void)removeContains:(NSSet *)values;

@end
