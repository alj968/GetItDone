//
//  GITAppointmentManagerTests.m
//  GetItDone
//
//  Created by Amanda Jones on 2/20/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GITDatabaseHelper.h"
#import "GITDatabaseHelper+Private.h"
#import "GITAppointmentManager.h"
#import "GITAppointment.h"

@interface GITAppointmentManagerTests : XCTestCase

@end

@implementation GITAppointmentManagerTests

#pragma mark - Set up and tear down
//Gets called between each test
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

#pragma mark - Tests for makeAppointmentAndSaveWithTitle
#pragma mark Making appointments

/*
 Verifies: Appointment added to database
 */
-(void)testMakeAppointmentOkay
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    XCTAssertEqual(appointment.title, title, @"Mismatch on apointment title");
    XCTAssertEqualObjects(appointment.start_time, startDate, @"Mismatch on appointment start");
    XCTAssertEqualObjects(appointment.end_time, endDate, @"Mismatch on appointment end");
    XCTAssertEqual(appointment.event_description, description, @"Mismatch on appointment description");
}

/*
 Verifies: If all params nil, will not make appointment and will return nil
 */
-(void)testMakeAppointmentAllNilParams
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:nil startDate:nil endDate:nil description:nil forAppointment:nil];
    XCTAssertNil(appointment, @"Appointment returned should be nil");
}

/*
 Verifies: If title is nil, will fill in title and make appointment
 */
-(void)testMakeAppointmentTitleNil
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:nil startDate:startDate endDate:endDate description:description forAppointment:nil];
    XCTAssertNotNil(appointment, @"Appointment returned should not be nil");
    XCTAssertEqualObjects(appointment.title, @"New Appointment", @"Title of appointment is incorrect.");
}


/*
 Verifies: If required param, such as start time, is nil, will not make appointment and will return nil
 */
-(void)testMakeAppointmentTimeNil
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:nil description:description forAppointment:nil];
    XCTAssertNil(appointment, @"Appointment returned should be nil");
}

/*
 Verifies: If start time later than finish time, returns nil for appointment
 */
-(void)testMakeAppointmentStartEarlierThanFinish
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    XCTAssertNil(appointment, @"Appointment returned should be nil");
}

/*
 Verifies: If end time same as start time, returns nil for appointment
 */
-(void)testMakeAppointmentStartEqualsFinish
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = startDate;
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    XCTAssertNil(appointment, @"Appointment returned should be nil");
}


/*
 Verifies: If non-required param, such as description, is nil, will still make appointment in db
 */
-(void)testMakeAppointmentDescriptionNil
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:nil forAppointment:nil];
    XCTAssertNotNil(appointment, @"Appointment should have been created, even without description");
    XCTAssertEqual(appointment.title, title, @"Mismatch on apointment title");
    XCTAssertEqualObjects(appointment.start_time, startDate, @"Mismatch on appointment start");
    XCTAssertEqualObjects(appointment.end_time, endDate, @"Mismatch on appointment end");
    NSString *description = appointment.event_description;
    XCTAssertNil(description, @"Description should be nil");
}

/*
 Verifies: Appointment with time conflict cannot be added to db
 */
-(void)testMakeAppointmentSameAppointmentTwice
{
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    XCTAssertNotNil(appointment, @"Added first apointment successfully");
    
    GITAppointment *appointment2 = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    XCTAssertNil(appointment2, @"Failed to add second appointment with overlapping time");
    
}

#pragma mark Editing appointments
/*
 Verifies: Able to edit appointment title
 */
-(void)testEditingAppointmentOkay
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"New Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Edit title
    NSString *newTitle = @"New title";
    appointment = [appointManager makeAppointmentAndSaveWithTitle:newTitle startDate:startDate endDate:endDate description:description forAppointment:appointment];
    XCTAssertEqual(appointment.title, newTitle, @"Mismatch on apointment title");
    XCTAssertEqualObjects(appointment.start_time, startDate, @"Mismatch on appointment start");
    XCTAssertEqualObjects(appointment.end_time, endDate, @"Mismatch on appointment end");
    XCTAssertEqual(appointment.event_description, description, @"Mismatch on appointment description");
}

/*
 Verifies: If editing appointment and title is removed, a title is given to it
 */
-(void)testEditingAppointmentRemovingTitle
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Edit title
    appointment = [appointManager makeAppointmentAndSaveWithTitle:nil startDate:startDate endDate:endDate description:description forAppointment:appointment];
    XCTAssertEqualObjects(appointment.title, @"New Appointment", @"Mismatch on apointment title");
    XCTAssertEqualObjects(appointment.start_time, startDate, @"Mismatch on appointment start");
    XCTAssertEqualObjects(appointment.end_time, endDate, @"Mismatch on appointment end");
    XCTAssertEqual(appointment.event_description, description, @"Mismatch on appointment description");
}

/*
 Verifies: If editing appointment and start time is removed, appointment is nil
 */
-(void)testEditingAppointmentRemovingTime
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Edit time
    appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:nil endDate:endDate description:description forAppointment:appointment];
    XCTAssertNil(appointment, @"Appointment should be nil");
}

/*
 Verifies: If editing appointment and crucial piece (such as start time) removed, so as to make the returned appointment nil, that orgiinal appointment made still exists in db
 */
-(void)testEditingOriginalExists
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Edit time
    appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:nil endDate:endDate description:description forAppointment:appointment];
    XCTAssertNil(appointment, @"Appointment should be nil");
    
    //Make sure original appointment still exists
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
    XCTAssertNotNil(originalEvent, @"Should have found original appointment");
    XCTAssertEqualObjects(originalEvent.title, title, @"Title should match");
}

/*
 Verifies: When editing a task, removing noncrucial information, such as description, just removes that piece of information
 */
-(void)testEditingAppointmentRemovingDescription
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Remove description
    appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:nil forAppointment:appointment];
    XCTAssertNotNil(appointment, @"Appointment should not be nil after removing description");
    XCTAssertNil(appointment.event_description, @"Description should be nil after removing it");
}


/*
 Verifies: If editing appointment and start time changed to same as end time, returns nil
 */
-(void)testEditingAppointmentSameStartEnd
{
    //Make appointment - this will work based on other test
    GITAppointmentManager *appointManager = [[GITAppointmentManager alloc] init];
    NSString *title = @"Appointment";
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
    NSString *description = @"This is a test";
    GITAppointment *appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:startDate endDate:endDate description:description forAppointment:nil];
    
    //Edit time
    appointment = [appointManager makeAppointmentAndSaveWithTitle:title startDate:endDate endDate:endDate description:description forAppointment:appointment];
    XCTAssertNil(appointment, @"Appointment should be nil");
}

@end
