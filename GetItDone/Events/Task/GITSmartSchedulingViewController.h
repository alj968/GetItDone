//
//  GITSmartSchedulingViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/9/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITDatebaseHelper.h"

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

//TODO: Later change this so it selects a random time slot from the time slot table in db
//TODO: Later change this so it looks up priority and uses this to find the time period instead of just assuming one week
/**
 Suggestions a random date (including time) for a task that does not conflict with any existing event's date.
 @param duration The length of the task for which a time slot must be found.
 */
-(NSDate *)makeTimeSuggestionForDuration:(NSNumber *)duration;

@end
