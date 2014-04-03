//
//  GITTimeSlotTableViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/16/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITSetUpDatabase.h"
//TODO CLEANUP: Remove whole .m and .h class when done testing
@interface GITTimeSlotTableViewController : UITableViewController

/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;
/**
 The array of all time slots in the database
 */
@property (nonatomic , strong) NSArray *timeSlots;

@end
