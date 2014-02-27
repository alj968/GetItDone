//
//  GITCategoryViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/29/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITCategoryManager.h"
#import "GITDatabaseHelper.h"
@class GITCategoryViewController;

/**
 Defines the methods in the CategoryDelegate
 */
@protocol GITCategoryDelegate <NSObject>

/**
 Sets the cateogry title selected, using the selections,
 in the GITAddTaskViewController
 @param controller The category view controller
 @param categoryTitle The category title chosen
 */
- (void)categoryViewController:(GITCategoryViewController *)controller finishedWithCategoryTitle:(NSString *)categoryTitle;

@end

/**
 The view controller that allows the user to pick an existing category, or create a new category, for a task being created on the AddTaskViewController screen
 */
@interface GITCategoryViewController : UITableViewController

/**
 Delegate for Category Controller
 */
@property (nonatomic) id<GITCategoryDelegate> delegate;
/**
 The entity manager for category
 */
@property (nonatomic, strong) GITCategoryManager *categoryManager;
/**
 Array of existing categories
 */
@property (strong, nonatomic) NSMutableArray *categoryOptionsArray;
/**
 The button allowing user to add a new category
 */
@property (strong, nonatomic) UIButton *buttonAddCategory;
/**
 Keeps track of when the add new category button pressed
 */
- (void)buttonPressedAddCategory:(id)sender;
/**
 The category chosen from the table, or the new category made
 */
@property (strong, nonatomic) NSString *categoryTitle;

@end
