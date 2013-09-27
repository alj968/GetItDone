//
//  GITDatebaseHelper.h
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface GITDatebaseHelper : NSObject
/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

- (void) makeEventAndSaveWithTitle:(NSString *)title
                      andStartDate:(NSDate *)start
                        andEndDate:(NSDate *)end
                       andTaskBool:(NSString *)taskBool
                       andDuration:(NSString *)duration
                          forEvent:(Event *)event;

- (BOOL) saveEventSuccessful;

- (void) printDatabase;

- (NSNumber *)durationStringToNumber:(NSString *)durationString;

- (NSNumber *)taskStringToNumber:(NSString *)taskString;

-(NSString *)taskNumberToString:(NSNumber *)taskNumber;

@end
