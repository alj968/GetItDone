//
//  AddEventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 8/28/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
/**
 Allows user to add an event to the calendar.
 */
#import <UIKit/UIKit.h>
///!! make into static table view - look up how to do

@interface AddEventViewController : UIViewController
/**
 NSManagedObjectContext for core data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;
- (IBAction)addEventButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *titleTextBox;
@property (strong, nonatomic) IBOutlet UITextField *startTimeTextBox;
@property (strong, nonatomic) IBOutlet UITextField *endTimeTextBox;
@property (strong, nonatomic) IBOutlet UITextField *durationTextBox;
@property (strong, nonatomic) IBOutlet UITextField *taskTextBox;

@end
