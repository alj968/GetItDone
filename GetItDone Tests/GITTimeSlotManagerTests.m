//
//  GITTimeSlotManagerTests.m
//  GetItDone
//
//  Created by Amanda Jones on 2/21/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GITDatabaseHelper.h"
#import "GITDatabaseHelper+Private.h"
#import "GITTimeSlotManager.h"
#import "GITTimeSlotManager+Private.h"
#import "GITProjectConstants.h"
#import "GITTimeSlot.h"

@interface GITTimeSlotManagerTests : XCTestCase

@end

@implementation GITTimeSlotManagerTests

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

#pragma mark - Tests for getChangeByNumberForAction
/**
 Verifies that for an accept, the change by number for the time slot table is 1
 */
-(void)testChangeByNumberAccept
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:kGITUserActionAccept];
    XCTAssert(changeBy == 1, @"Should change by 1 for accept");
}

/**
 Verifies that for an reject, the change by number for the time slot table is -1
 */
-(void)testChangeByNumberReject
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:kGITUserActionReject];
    XCTAssert(changeBy == -1, @"Should change by -1 for reject");
}

/**
 Verifies that for a "do", the change by number for the time slot table is 2
 */
-(void)testChangeByNumberDo
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:kGITUserActionDo];
    XCTAssert(changeBy == 2, @"Should change by 2 for do");
}

/**
 Verifies that for a postpone, the change by number for the time slot table is -2
 */
-(void)testChangeByNumberPostpone
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:kGITUserActionPostpone];
    XCTAssert(changeBy == -2, @"Should change by -2 for do");
}

/**
 Verifies that for a nil action, the change by number for the time slot table is 0
 */
-(void)testChangeByNumberNilAction
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:nil];
    XCTAssert(changeBy == 0, @"Should change by 0 for nil action");
}

/**
 Verifies that for a non- action, the change by number for the time slot table is 0
 */
-(void)testChangeByNumberRandomAction
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    int changeBy = [timeSlotManager getChangeByNumberForAction:@"Action"];
    XCTAssert(changeBy == 0, @"Should change by 0 for random action");
}

# pragma mark - Tests for isTimeSlotAtSameTimeAs
/**
 Verifies that the same time slot twice return as having the same time
 */
-(void)testSameTimeSameSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTime = [timeSlotManager isTimeSlot:timeSlot1 AtSameTimeAs:timeSlot2];
    XCTAssertTrue(sameTime, @"Slots are same so should have same time");
}

/**
 Verifies that two slots with the same time return as having the same time
 */
-(void)testSameTimeOkay
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Tuesday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTime = [timeSlotManager isTimeSlot:timeSlot1 AtSameTimeAs:timeSlot2];
    XCTAssertTrue(sameTime, @"Slots have same time so should be true");
}

/**
 Verifies that two slots with the different times return as not having the same time
 */
-(void)testSameTimeNotSame
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:3]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTime = [timeSlotManager isTimeSlot:timeSlot1 AtSameTimeAs:timeSlot2];
    XCTAssertFalse(sameTime, @"Slots have different times so should be false");
 
}

/**
 Verifies that one nil slot returns as the time slots not having the same time
 */
-(void)testSameTimeNilTimeSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    BOOL sameTime = [timeSlotManager isTimeSlot:timeSlot1 AtSameTimeAs:nil];
    XCTAssertFalse(sameTime, @"One slot is nil so should be false");
}

/**
 Verifies that both nil slots returns as the time slots not having the same time
 */
-(void)testSameTimeTwoNilTimeSlots
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    BOOL sameTime = [timeSlotManager isTimeSlot:nil AtSameTimeAs:nil];
    XCTAssertFalse(sameTime, @"Both slots nil so should be false");
}

#pragma mark - Tests for isTimeSlotOnSameDayAs
/**
 Verfies that same time slot twice comes back as being on the same day
 */
-(void)testSameDaySameSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDay = [timeSlotManager isTimeSlot:timeSlot1 OnSameDayAs:timeSlot2];
    XCTAssertTrue(sameDay, @"Slots are same so should have same day");
}

/**
 Verfies that two time slots with the same day comes back as true
 */
-(void)testSameDayOkay
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Saturday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Saturday" hour:[NSNumber numberWithInt:3]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDay = [timeSlotManager isTimeSlot:timeSlot1 OnSameDayAs:timeSlot2];
    XCTAssertTrue(sameDay, @"Slots have same day so should be true");
}

/**
 Verfies that two time slots with the different days comes back as false
 */
-(void)testSameDayDifferentDays
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Tuesday" hour:[NSNumber numberWithInt:3]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:3]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDay = [timeSlotManager isTimeSlot:timeSlot1 OnSameDayAs:timeSlot2];
    XCTAssertFalse(sameDay, @"Slots don't have same day so should be false");
}

/**
 Verifies that one nil slot returns as the time slots not having the same day
 */
-(void)testSameDayNilTimeSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    BOOL sameDay = [timeSlotManager isTimeSlot:timeSlot1 OnSameDayAs:nil];
    XCTAssertFalse(sameDay, @"One slot is nil so should be false");
}

/**
 Verifies that both nil slots returns as the time slots not having the same day
 */
-(void)testSameDayTwoNilTimeSlots
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    BOOL sameDay = [timeSlotManager isTimeSlot:nil OnSameDayAs:nil];
    XCTAssertFalse(sameDay, @"Both slots nil so should be false");
}

#pragma mark - Tests for isTimeSlotInSameTimeGroupAs
/**
 Verifies that two of the same slots come back as true
 */
-(void)testSameTimeGroupSameSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Wednesday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Wednesday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTimeGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameTimeGroupAs:timeSlot2];
    XCTAssertTrue(sameTimeGroup, @"Slots are same so should have same time group");
}

/**
 Verifies that two slots in the same time group come back as true
 */
-(void)testSameTimeGroupOkay
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Sunday" hour:[NSNumber numberWithInt:1]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTimeGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameTimeGroupAs:timeSlot2];
    XCTAssertTrue(sameTimeGroup, @"Slots are in same time group so should be true");
}

/**
 Verifies that two slots in different time groups comes back as false
 */
-(void)testSameTimeGroupDifferentGroups
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:3]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:13]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameTimeGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameTimeGroupAs:timeSlot2];
    XCTAssertFalse(sameTimeGroup, @"Slots aren't in the same time group so should be false");
}

/**
 Verifies that one nil slot comes back as false
 */
-(void)testSameTimeGroupNilTimeSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    BOOL sameTimeGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameTimeGroupAs:nil];
    XCTAssertFalse(sameTimeGroup, @"One slot is nil so should be false");
}

/**
 Verifies that two nil slots comes back as false
 */
-(void)testSameTimeGroupTwoNilTimeSlots
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    BOOL sameTimeGroup = [timeSlotManager isTimeSlot:nil InSameTimeGroupAs:nil];
    XCTAssertFalse(sameTimeGroup, @"Both slots nil so should be false");
}



#pragma mark - Tests for isTimeSlotInSameDayGroupAs
/**
 Verifies that two slots that are the same come back as in the same day group
 */
-(void)testSameDayGroupSameSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Saturday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Saturday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameDayGroupAs:timeSlot2];
    XCTAssertTrue(sameDayGroup, @"Slots are same so should have same day group");
}

/**
 Verifies that two slots in the same day group come back as true (weekdays)
 */
-(void)testSameTimeGroupOkayWeekday
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Tuesday" hour:[NSNumber numberWithInt:1]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameDayGroupAs:timeSlot2];
    XCTAssertTrue(sameDayGroup, @"Slots are in same day group so should be true");
}

/**
 Verifies that two slots in the same day group come back as true (weekends)
 */
-(void)testSameTimeGroupOkayWeekend
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Saturday" hour:[NSNumber numberWithInt:2]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Sunday" hour:[NSNumber numberWithInt:12]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameDayGroupAs:timeSlot2];
    XCTAssertTrue(sameDayGroup, @"Slots are in same day group so should be true");
}

/**
 Verifies that two slots in different day groups comes back as false
 */
-(void)testSameDayGroupDifferentGroups
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:3]];
    GITTimeSlot *timeSlot2 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Sunday" hour:[NSNumber numberWithInt:3]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    XCTAssertNotNil(timeSlot2, @"Second time slot should not be  nil");
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameDayGroupAs:timeSlot2];
    XCTAssertFalse(sameDayGroup, @"Slots aren't in the same day group so should be false");
}

/**
 Verifies that one nil slot comes back as false
 */
-(void)testSameDayGroupNilTimeSlot
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    GITTimeSlot *timeSlot1 = [helper addTimeSlotWithCategoryTitle:@"None" dayOfWeek:@"Monday" hour:[NSNumber numberWithInt:2]];
    XCTAssertNotNil(timeSlot1, @"First time slot should not be  nil");
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:timeSlot1 InSameDayGroupAs:nil];
    XCTAssertFalse(sameDayGroup, @"One slot is nil so should be false");
}

/**
 Verifies that two nil slots comes back as false
 */
-(void)testSameDayGroupTwoNilTimeSlots
{
    GITTimeSlotManager *timeSlotManager = [[GITTimeSlotManager alloc] init];
    BOOL sameDayGroup = [timeSlotManager isTimeSlot:nil InSameDayGroupAs:nil];
    XCTAssertFalse(sameDayGroup, @"Both slots nil so should be false");
}

@end
