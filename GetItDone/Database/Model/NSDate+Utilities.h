//
//  NSDate+Utilities.h
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A category on NSDate
 */
@interface NSDate (Utilities)

/**
 Makes an NSDate to be used when making an event
 @param nsinteger Year
 @param nsinteger Month
 @param nsinteger Day
 @param nsinteger Hour
 @param nsinteger Minutes
 @param nsinteger Second
 @return nsdate Date to be created
 */
+ (NSDate *)dateWithTime:(NSInteger)year
                       month:(NSInteger)month
                         day:(NSInteger)day
                        hour:(NSInteger)hour
                     minutes:(NSInteger)minutes
                     seconds:(NSInteger)second;

/**
 Makes an NSDate with the given info, automatically setting the time to be 12:00 AM
 @param nsinteger Year
 @param nsinteger Month
 @param nsinteger Day
 @return nsdate Date to be created
 */
+ (NSDate *)makeAllDayDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end
