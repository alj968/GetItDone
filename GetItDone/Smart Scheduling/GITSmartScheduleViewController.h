//
//  GITSmartScheduleViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 9/24/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GITDatebaseHelper.h"

//TODO: Comment class
@interface GITSmartScheduleViewController : UIViewController

@property (nonatomic, strong) NSDate *randomDate;

/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Event to be added
 */
@property (nonatomic, strong) Event *event;

@property (nonatomic, strong) GITDatebaseHelper *helper;


- (IBAction)smartScheduleButtonSelected:(id)sender;

@end
