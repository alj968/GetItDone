//
//  GITDatabaseHelper+Private.h
//  GetItDone
//
//  Created by Amanda Jones on 2/20/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITDatabaseHelper.h"

@interface GITDatabaseHelper (Private)

- (BOOL)deleteAllEvents;

- (BOOL)deleteAllCategoriesAndTimeSlots;

- (GITTimeSlot *)addTimeSlotWithCategoryTitle:(NSString *)categoryTitle dayOfWeek:(NSString *)dayOfWeek hour:(NSNumber *)hour;

@end
