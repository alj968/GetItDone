//
//  SetUpScheduleViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 For testing purposes. This will later be removed once I set up creating events interface. For now, initalizes database with events and dispalys table view with times of day.
 */
#import <UIKit/UIKit.h>

@interface SetUpScheduleViewController : UIViewController

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Initalizes database with events
 */
- (IBAction)setUpEvents:(id)sender;

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
- (NSDate *)makeDateWithYear:(NSInteger)year
                       month:(NSInteger)month
                         day:(NSInteger)day
                        hour:(NSInteger)hour
                     minutes:(NSInteger)minutes
                     seconds:(NSInteger)second;


@end
