//
//  GITCategoryViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 1/29/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITCategoryManager.h"

@interface GITCategoryViewController : UITableViewController

/**
 The entity manager for category
 */
@property (nonatomic, strong) GITCategoryManager *categoryManager;
/**
 Array of values for category picker view. Contains exsiting categories, and the option to make a new one
 */
@property (strong, nonatomic) NSMutableArray *categoryOptionsArray;


@end
