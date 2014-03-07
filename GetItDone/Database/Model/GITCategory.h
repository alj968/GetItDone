//
//  GITCategory.h
//  GetItDone
//
//  Created by Amanda Jones on 3/5/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GITTask, GITTimeSlot;

/**
 The model class for the GITCategory entity
 */
@interface GITCategory : NSManagedObject

/**
 The title of the category. Required.
 */
@property (nonatomic, retain) NSString * title;
/**
 The tasks associated with the category. Optional.
 */
@property (nonatomic, retain) NSSet *contains;
/**
 The time slots associated with the category. Optional.
 */
@property (nonatomic, retain) NSSet *correspondsTo;
@end

@interface GITCategory (CoreDataGeneratedAccessors)

- (void)addContainsObject:(GITTask *)value;
- (void)removeContainsObject:(GITTask *)value;
- (void)addContains:(NSSet *)values;
- (void)removeContains:(NSSet *)values;

- (void)addCorrespondsToObject:(GITTimeSlot *)value;
- (void)removeCorrespondsToObject:(GITTimeSlot *)value;
- (void)addCorrespondsTo:(NSSet *)values;
- (void)removeCorrespondsTo:(NSSet *)values;

@end
