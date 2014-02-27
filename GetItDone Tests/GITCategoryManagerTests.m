//
//  GITCategoryManagerTests.m
//  GetItDone
//
//  Created by Amanda Jones on 2/21/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GITDatabaseHelper.h"
#import "GITDatabaseHelper+Private.h"
#import "GITCategoryManager.h"
#import "GITCategory.h"

@interface GITCategoryManagerTests : XCTestCase

@end

@implementation GITCategoryManagerTests

#pragma mark - Set up and tear down

- (void)setUp
{
    [super setUp];
}

//Called after every test
- (void)tearDown
{
    [super tearDown];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    [helper deleteAllCategoriesAndTimeSlots];
    //Re-establish default category
    [helper makeCategoryWithTitle:@"None"];
}


#pragma mark - Tests for addCategoryWithTitle
/**
 Verifies: Adding a new category (with a name that doesn't already exists) adds the new category to the db
 */
-(void)testAddCategoryOkay
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle = @"New";
    GITCategory *category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNotNil(category, @"Category should not be nil");
    XCTAssertEqualObjects(category.title, categoryTitle, @"New category's title should be title inputted");
}

/**
 Verifies: Adding multiple categories with distinct names is successful
 */
-(void)testAddMultipleCategories
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle1 = @"Category 1";
    GITCategory *category1 = [categoryManager addCategoryWithTitle:categoryTitle1 error:&error];
    XCTAssertNotNil(category1, @"Category 1 should not be nil");
    XCTAssertEqualObjects(category1.title, categoryTitle1, @"New category's title should be title inputted");
    
    NSString *categoryTitle2 = @"Category 2";
    GITCategory *category2 = [categoryManager addCategoryWithTitle:categoryTitle2 error:&error];
    XCTAssertNotNil(category2, @"Category 2 should not be nil");
    XCTAssertEqualObjects(category2.title, categoryTitle2, @"New category's title should be title inputted");
    
    NSString *categoryTitle3 = @"Category 3";
    GITCategory *category3 = [categoryManager addCategoryWithTitle:categoryTitle3 error:&error];
    XCTAssertNotNil(category3, @"Category 3 should not be nil");
    XCTAssertEqualObjects(category3.title, categoryTitle3, @"New category's title should be title inputted");
}


/**
 Verifies: Adding a new category, with name that already exists, returns an error and a nil category
 */
-(void)testAddCategoryTitleRepeat
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle = @"New";
    GITCategory *category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNotNil(category, @"Category should not be nil");
    
    category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNil(category, @"Category should be nil because name already exists");
    XCTAssertNotNil(error, @"Error should no be nil");
}

/**
 Verifies: Adding a new category with a nil title returns an error and a nil category
 */
-(void)testAddCategoryTitleNil
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    GITCategory *category = [categoryManager addCategoryWithTitle:nil error:&error];
    XCTAssertNil(category, @"Category should be nil");
    XCTAssertNotNil(error, @"Error should no be nil");
}

/**
 Verifies: Adding a new category with a empty string as title returns an error and a nil category
 */
-(void)testAddCategoryTitleEmptyString
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    GITCategory *category = [categoryManager addCategoryWithTitle:@"" error:&error];
    XCTAssertNil(category, @"Category should be nil");
    XCTAssertNotNil(error, @"Error should no be nil");
}

#pragma mark - Tests for getAllCategoryTitles
/**
 Verifies: Adding two categories, then getting the category list, returns the categories just added
 */
-(void)testGetAllCategoryTitlesCategoriesAdded
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    
    NSString *categoryTitle1 = @"Category 1";
    GITCategory *category1 = [categoryManager addCategoryWithTitle:categoryTitle1 error:&error];
    XCTAssertNotNil(category1, @"Category should not be nil");
    
    NSString *categoryTitle2 = @"Category 2";
    GITCategory *category2 = [categoryManager addCategoryWithTitle:categoryTitle2 error:&error];
    XCTAssertNotNil(category2, @"Category should not be nil");
    
    NSArray *categories = [categoryManager getAllCategoryTitles];
    XCTAssert(categories.count == 3, @"Should be two categories");
    NSString *title1 = [categories objectAtIndex:1];
    XCTAssertEqualObjects(categoryTitle1, title1, @"Titles for category 1 should match");
    NSString *title2 = [categories objectAtIndex:2];
    XCTAssertEqualObjects(categoryTitle2, title2, @"Titles for category 2 should match");
}

/**
 Verifies: Adding no categories, then getting the category list, returns empty array
 */
-(void)testGetAllCategoryTitlesNoCategories
{
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    [helper deleteAllCategoriesAndTimeSlots];
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSArray *categories = [categoryManager getAllCategoryTitles];
    XCTAssertNotNil(categories, @"Categories title array should not be nil - should be empty array");
    XCTAssert(categories.count == 0, @"The array of categories should have size 0");
}

/**
 Verifies: Adding two categories, one failing, then getting the category list, returns only the first category added
 */
-(void)testGetAllCategoryTitlesOneSuccessfulCategory
{
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    
    NSString *categoryTitle1 = @"Category 1";
    GITCategory *category1 = [categoryManager addCategoryWithTitle:categoryTitle1 error:&error];
    XCTAssertNotNil(category1, @"Category should not be nil");
    
    GITCategory *category2 = [categoryManager addCategoryWithTitle:categoryTitle1 error:&error];
    XCTAssertNil(category2, @"Second category should be nil");
    
    NSArray *categories = [categoryManager getAllCategoryTitles];
    XCTAssert(categories.count == 2, @"Should be one category");
    NSString *title1 = [categories objectAtIndex:1];
    XCTAssertEqualObjects(categoryTitle1, title1, @"Titles for category 1 should match");
}

# pragma mark - Tests for deleteCategoryWithTitle
/**
 Verifies: Deleting a category, with no tasks associated with it, is successful
 */
-(void)testDeleteCategoryNoTasks
{
    //Make category, won't have any tasks
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle = @"New";
    GITCategory *category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNotNil(category, @"Category should not be nil");

    //Delete it
    BOOL categoryDeleted = [categoryManager deleteCategoryForTitle:categoryTitle withError:&error];
    XCTAssertTrue(categoryDeleted, @"Category should have been deleted");
}

/**
 Verifies: Deleting a category, with a nil title param, is unsuccessful
 */
-(void)testDeleteCategoryNilTitle
{
    //Make category, won't have any tasks
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    
    //Delete it
    BOOL categoryDeleted = [categoryManager deleteCategoryForTitle:nil withError:&error];
    XCTAssertFalse(categoryDeleted, @"Category should not have been deleted");
}

/**
 Verifies: Deleting a category, with an upcoming tasks associated with it, is unsuccessful
 */
-(void)testDeleteCategoryUpcomingTask
{
    //Make category
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle = @"New";
    GITCategory *category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNotNil(category, @"Category should not be nil");
    
    //Make upcoming task and assign it to this category
    NSDate *upcomingDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*2];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    [helper makeTaskAndSaveWithTitle:@"Title" startDate:upcomingDate endDate:[upcomingDate dateByAddingTimeInterval:60*60] description:nil duration:[NSNumber numberWithInt:60] category:category deadline:nil priority:nil forTask:nil];
    
    //Delete it
    BOOL categoryDeleted = [categoryManager deleteCategoryForTitle:categoryTitle withError:&error];
    XCTAssertFalse(categoryDeleted, @"Category should not have been deleted");
}

/**
 Verifies: Deleting a category, with a past task associated with it, is successful
 */
-(void)testDeleteCategoryOldTask
{
    //Make category
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    GITCategory *category = [categoryManager addCategoryWithTitle:@"New" error:&error];
    XCTAssertNotNil(category, @"Newly created category should not be nil");
    
    //Make old task and assign it to this category
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    NSDate *pastDate = [[NSDate date] dateByAddingTimeInterval:-60*60*24*2];
    [helper makeTaskAndSaveWithTitle:@"Title" startDate:pastDate endDate:[pastDate dateByAddingTimeInterval:60*60] description:nil duration:[NSNumber numberWithInt:60] category:category deadline:nil priority:nil forTask:nil];
    
    //Delete it
    BOOL categoryDeleted = [categoryManager deleteCategoryForTitle:@"None" withError:&error];
    XCTAssertTrue(categoryDeleted, @"Category should have been deleted because task has passed");
}

/**
 Verifies: Deleting a category, with a past task and upcoming task associated with it, is unsuccessful
 */
-(void)testDeleteCategoryUpcomingTaskOldTask
{
    //Make category
    GITCategoryManager *categoryManager = [[GITCategoryManager alloc] init];
    NSError *error;
    NSString *categoryTitle = @"New";
    GITCategory *category = [categoryManager addCategoryWithTitle:categoryTitle error:&error];
    XCTAssertNotNil(category, @"Category should not be nil");
    
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    
    //Make upcoming task and assign it to this category
    NSDate *upcomingDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*2];
    [helper makeTaskAndSaveWithTitle:@"Title1" startDate:upcomingDate endDate:[upcomingDate dateByAddingTimeInterval:60*60] description:nil duration:[NSNumber numberWithInt:60] category:category deadline:nil priority:nil forTask:nil];
    
    //Make old task and assign it to this category
    NSDate *pastDate = [[NSDate date] dateByAddingTimeInterval:-60*60*24*2];
    [helper makeTaskAndSaveWithTitle:@"Title2" startDate:pastDate endDate:[pastDate dateByAddingTimeInterval:60*60] description:nil duration:[NSNumber numberWithInt:60] category:category deadline:nil priority:nil forTask:nil];
    
    //Delete it
    BOOL categoryDeleted = [categoryManager deleteCategoryForTitle:categoryTitle withError:&error];
    XCTAssertFalse(categoryDeleted, @"Category should not have been deleted");
}

@end
