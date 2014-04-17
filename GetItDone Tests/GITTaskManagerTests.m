//
//  GITTaskManagerTests.m
//  GetItDone
//
//  Created by Amanda Jones on 2/20/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GITDatabaseHelper.h"
#import "GITDatabaseHelper+Private.h"
#import "GITTaskManager.h"
#import "GITTask.h"
#import "GITEvent.h"

@interface GITTaskManagerTests : XCTestCase

@end

@implementation GITTaskManagerTests

#pragma mark - Set up and tear down

- (void)setUp
{
    [super setUp];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    [helper deleteAllEvents];
}

+ (void)tearDown
{
    [super tearDown];
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    [helper deleteAllEvents];
}
#pragma mark - Tests for makeTaskAndSaveWithTitle
#pragma mark Make task
/*
Verifies: Task added to database 
 (Category "None" made in set up so this is valid)
*/
-(void)testMakeTaskAllInfoOkay
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSDate *startDate = [NSDate date];
    NSString *description = @"This is a test";
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    //Deadline two weeks after start date
    NSDate *deadline = [startDate dateByAddingTimeInterval:60*60*24*14];
    NSNumber *priority = [NSNumber numberWithInt:1];
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:description duration:duration categoryTitle:categoryTitle deadline:deadline priority:priority forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    XCTAssertEqualObjects(task.title, title, @"Mismatch on title");
    XCTAssertEqualObjects(task.start_time, startDate, @"Mismatch on start time");
    XCTAssertEqualObjects(task.event_description, description, @"Mismatch on description");
    XCTAssertEqualObjects(task.deadline, deadline, @"Mismatch on deadline");
    XCTAssertEqualObjects(task.priority, priority, @"Mismatch on priority");
    XCTAssertEqualObjects(task.belongsTo.title, categoryTitle, @"Mismatch on category title");
    XCTAssertEqualObjects(task.duration, duration, @"Mismatch on duration");
    NSDate *endDate = [startDate dateByAddingTimeInterval:[duration intValue]*60];
    XCTAssertEqualObjects(task.end_time, endDate, @"Mismatch on endDate");
}


/*
 Verifies: Task with missing title gets made with default title
 */
-(void)testMakeTaskNoTitle
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *defaultTitle = @"New Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:nil startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    XCTAssertEqualObjects(task.title, defaultTitle, @"Mismatch on title");
}

/*
 Verifies: Task with missing duration doesn't get made and returns nil
 */
-(void)testMakeTaskNoDuration
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSDate *startDate = [NSDate date];
    NSString *categoryTitle = @"None";
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:nil categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNil(task, @"Task should be nil");
}

/*
 Verifies: Task added to database with just minimal information
 */
-(void)testMakeTaskOnlyRequiredInfo
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    XCTAssertEqualObjects(task.title, title, @"Mismatch on title");
    XCTAssertEqualObjects(task.start_time, startDate, @"Mismatch on start time");
    XCTAssertEqualObjects(task.belongsTo.title, categoryTitle, @"Mismatch on category title");
    XCTAssertEqualObjects(task.duration, duration, @"Mismatch on duration");
}

/*
 Verifies: Task with all nil params returns nil
 */
-(void)testMakeTaskAllNil
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:nil startDate:nil description:nil duration:nil categoryTitle:nil deadline:nil priority:nil forTask:nil];
    XCTAssertNil(task, @"Task should be nil");
}

/*
 Verifies: Task with missing start time doesn't get made and returns nil
 */
-(void)testMakeTaskNoStartTime
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:nil description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNil(task, @"Task should be nil");
}

/*
 Verifies: Task with missing category gets assigned category "none"
 */
-(void)testMakeTaskNoCategory
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:nil deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    XCTAssertEqualObjects(task.belongsTo.title, @"None", @"Category title should be 'none'");
}

#pragma mark Edit task methods
/**
 Verifies: Editing a non-crucial part of the task, such as title, is successful
 */
-(void)testEditTaskEditTitleOkay
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"New Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    //Deadline two weeks after start date
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    
    NSString *newTitle = @"New Title";
    task = [taskManager makeTaskAndSaveWithTitle:newTitle startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:task];
    XCTAssertNotNil(task, @"Task after editing title should not be nil");
    XCTAssertEqualObjects(task.title, newTitle, @"Title of task should be updated");
}

/**
 Verifies: Removing the title causes the default title to be assigned
 */
-(void)testEditTaskRemoveTitle
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    //Deadline two weeks after start date
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    
    NSString *shouldBeTitle = @"New Task";
    task = [taskManager makeTaskAndSaveWithTitle:nil startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:task];
    XCTAssertNotNil(task, @"Task after editing title should not be nil");
    XCTAssertEqualObjects(task.title, shouldBeTitle, @"Title of task should be default value");
}

/**
 Verifies: Removing crucial piece, such as start time, causes nil to be returned and original task to stay entact
 */
-(void)testEditTaskRemoveStartOriginalEntact
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    //Deadline two weeks after start date
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    
    task = [taskManager makeTaskAndSaveWithTitle:title startDate:nil description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:task];
    XCTAssertNil(task, @"Task after removing start time should be nil");
    
    //Make sure original task still exists
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    NSArray *eventsToday = [helper fetchEventsOnDay:startDate];
    GITEvent *originalEvent;
    for(NSManagedObject *managedObject in eventsToday)
    {
        GITEvent *event = (GITEvent *)managedObject;
        if([event.start_time compare:startDate] == NSOrderedSame)
        {
            originalEvent = event;
        }
    }
    XCTAssertNotNil(originalEvent, @"Should have found original task");
    XCTAssertEqualObjects(originalEvent.title, title, @"Title should match");
}

/**
 Verifies: Removing crucial piece, such as duration, causes nil to be returned and original task to stay entact
 */
-(void)testEditTaskRemoveDurationOriginalEntact
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    //Deadline two weeks after start date
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    
    task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:nil categoryTitle:categoryTitle deadline:nil priority:nil forTask:task];
    XCTAssertNil(task, @"Task after removing duration should be nil");
    
    //Make sure original task still exists
    GITDatabaseHelper *helper = [[GITDatabaseHelper alloc] init];
    NSArray *eventsToday = [helper fetchEventsOnDay:startDate];
    GITEvent *originalEvent;
    for(NSManagedObject *managedObject in eventsToday)
    {
        GITEvent *event = (GITEvent *)managedObject;
        if([event.start_time compare:startDate] == NSOrderedSame)
        {
            originalEvent = event;
        }
    }
    XCTAssertNotNil(originalEvent, @"Should have found original task");
    XCTAssertEqualObjects(originalEvent.title, title, @"Title should match");
}

/**
 When editing task, removing a noncrucial piece of information, such as description, edits that appointment and just makes description nil
 */
-(void)testEditTaskRemoveDescription
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSString *title = @"Task";
    NSDate *startDate = [NSDate date];
    NSNumber *duration = [NSNumber numberWithInt:60];
    NSString *categoryTitle = @"None";
    NSString *description = @"This is a test";
    //Deadline two weeks after start date
    GITTask *task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:description duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:nil];
    XCTAssertNotNil(task, @"Task should not be nil");
    
    //Remove description
    task = [taskManager makeTaskAndSaveWithTitle:title startDate:startDate description:nil duration:duration categoryTitle:categoryTitle deadline:nil priority:nil forTask:task];
    XCTAssertNotNil(task, @"Task after removing description should not be nil");
    XCTAssertNil(task.event_description, @"Description should now be nil");
}


#pragma mark - Tests for isTaskInfoValidForDeadline
/*
 Verifies: Deadline one hour after current time - okay
 */
-(void)testDeadlineValidationDeadlineTwoHours
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSError *error;
    NSDate *deadline = [[NSDate date] dateByAddingTimeInterval:60*60*2];
    BOOL okay = [taskManager isTaskInfoValidForDeadline:deadline categoryTitle:@"None" error:&error];
    XCTAssertTrue(okay, @"Deadline should be fine");
}

/*
 Verifies: Deadline one hour after current time - okay
 */
-(void)testDeadlineValidationDeadlineOneHour
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSError *error;
    NSDate *deadline = [[NSDate date] dateByAddingTimeInterval:60*60];
    BOOL okay = [taskManager isTaskInfoValidForDeadline:deadline categoryTitle:@"None" error:&error];
    XCTAssertFalse(okay, @"Deadline should not be okay");
}

/*
 Verifies: Deadline less than one hour after current time not okay
 */
-(void)testDeadlineValidationDeadlineNow
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSError *error;
    NSDate *deadline = [NSDate date];
    BOOL okay = [taskManager isTaskInfoValidForDeadline:deadline categoryTitle:@"None" error:&error];
    XCTAssertFalse(okay, @"Deadline should not be ok");
}

/*
 Verifies: Deadline of nil returns false
 */
-(void)testDeadlineValidationDeadlineNil
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    NSError *error;
    BOOL okay = [taskManager isTaskInfoValidForDeadline:nil categoryTitle:@"None" error:&error];
    XCTAssertTrue(okay, @"Deadline was nil, and deadline optional, so this is fine");
}

#pragma mark - Tests for getDayPeriodForTaskPriority
/*
 Verifies: Priority low returns 2 days
 */
-(void)testDayPeriodPriorityLow
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    int dayPeriod = [taskManager getDayPeriodForTaskPriority:[NSNumber numberWithInt:1]];
    XCTAssertEqual(dayPeriod, 7, @"Day period for low priority should be 7");
}

/*
 Verifies: Priority medium returns 4 days
 */
-(void)testDayPeriodPriorityMedium
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    int dayPeriod = [taskManager getDayPeriodForTaskPriority:[NSNumber numberWithInt:2]];
    XCTAssertEqual(dayPeriod, 4, @"Day period for medium priority should be 4");
}

/*
 Verifies: Priority high returns 2 days
 */
-(void)testDayPeriodPriorityHigh
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    int dayPeriod = [taskManager getDayPeriodForTaskPriority:[NSNumber numberWithInt:3]];
    XCTAssertEqual(dayPeriod, 2, @"Day period for low priority should be 2");
}

/*
 Verifies: Priority low returns 7 days
 */
-(void)testDayPeriodPriorityNil
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    int dayPeriod = [taskManager getDayPeriodForTaskPriority:nil];
    XCTAssertEqual(dayPeriod, 7, @"Day period for nil priority should be 7");
}

/*
 Verifies: Priority with random number returns 7 days
 */
-(void)testDayPeriodPriorityRandomNumber
{
    GITTaskManager *taskManager = [[GITTaskManager alloc] init];
    int dayPeriod = [taskManager getDayPeriodForTaskPriority:[NSNumber numberWithInt:10]];
    XCTAssertEqual(dayPeriod, 7, @"Day period for random priority should be 7");
}
@end
