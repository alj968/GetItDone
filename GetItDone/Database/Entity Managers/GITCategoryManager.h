//
//  GITCategoryManager.h
//  GetItDone
//
//  Created by Amanda Jones on 1/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITDatabaseHelper.h"

/**
 It is responsible for all business logic for category, and communicates with the database helper so the database helper can perform the requested CRUD operations.
 */
@interface GITCategoryManager : NSObject

/**
 The database helper
 */
@property (nonatomic, strong) GITDatabaseHelper *helper;

/**
 Checks if a category with the given name already exists, and if not, asks the database helper to add a category with that name to the database. If it was added to the database, this class calls the database helper to create a corresponding time slot table
 @param name The name of the category
 @param error The error that will get initialized if category already exists, or if the db fails to add it
 @return Returns true if category doesn't already exist & was successfully added to db, false if category with that name already exists, or if database helper did not add it to the database 
 */
-(GITCategory *)addCategoryWithTitle:(NSString *)title error:(NSError **)error;

/**
 Calls the database helper to get all categories from the database and pulls out their titles and makes an array from them. If there are no categories in the database yet, this method makes an empty array.
 @return Returns an array with the list of names of the categories in the database, or an empty array if no categories are in the database.
 */
-(NSArray *)getAllCategoryTitles;

/**
 This method checks to see if the given title corresponds to an existing category. If it does, it checks if this category has any upcoming tasks associated with it. If not, it requests for the db helper to delete the category. Otherwise, it explains the problem by assigning error.
 @param title The title of the category to be deleted
 @param error The error as to why the category could not be deleted
 @return Returns true if the category was successfully deleted, false otherwise
 */
-(BOOL)deleteCategoryForTitle:(NSString *)title  withError:(NSError **)error;

@end
