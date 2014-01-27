//
//  GITSmartSchedulingViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatebaseHelper.h"
#import "GITTimeSlotManager.h"

@interface GITSmartSchedulingViewController : UIViewController

/**
 Random date found within a one week period of current date
 to be suggested
 TODO: Change this comment so it's not always one week period
 */
@property (nonatomic, strong) NSDate *randomDate;
/**
 The database helper
 */
@property (nonatomic, strong) GITDatebaseHelper *helper;
/**
 The entity manager for time slot
 */
@property (nonatomic, strong) GITTimeSlotManager *timeSlotManager;

/**
 Suggestions a date for the task that does not conflict with any existing event's date
 Selects from the time slot table for that category, starting with the time slot with the top weight
 @param duration The length of the task for which a time slot must be found
 @param categoryTitle The category title for the task to be scheduled
 @param dayPeriod The number of days within which the date should be. (Priority used to determine this)
 @return Returns a smart scheduling suggestion for the task to be scheduled
 */
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration andCategoryTitle:(NSString *)categoryTitle withinDayPeriod:(int)dayPeriod;
@end
