//
//  NSDate+Utilities.h
//  GetItDone
//
//  Created by Amanda Jones on 9/2/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utilities)

+ (NSDate *)makeDateWithYear:(NSInteger)year
                       month:(NSInteger)month
                         day:(NSInteger)day
                        hour:(NSInteger)hour
                     minutes:(NSInteger)minutes
                     seconds:(NSInteger)second;

@end
