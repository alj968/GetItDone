//
//  GITDatebaseHelper.m
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITDatebaseHelper.h"
#import "NSDate+Utilities.h"

@implementation GITDatebaseHelper

#pragma mark Set up methods

-(NSManagedObjectContext *)context
{
    if(!_context)
    {
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    }
    return _context;
}


#pragma mark Create/edit entity methods

- (BOOL) makeAppointmentAndSaveWithTitle:(NSString *)title
                               startDate:(NSDate *)start
                                 endDate:(NSDate *)end
                             description:(NSString *)description
                          forAppointment:(GITAppointment *)appointment
{
    if(!appointment)
    {
        appointment = [NSEntityDescription insertNewObjectForEntityForName:@"GITAppointment" inManagedObjectContext:self.context];
    }
    [appointment setTitle:title];
    [appointment setStart_time:start];
    [appointment setEnd_time:end];
    [appointment setEvent_description:description];
    return [self saveContextSuccessful];
}

- (BOOL) makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start endDate:(NSDate *) end description:(NSString *)description duration:(NSNumber *)duration category:(GITCategory *)category deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task
{
    if(!task)
    {
        task = [NSEntityDescription insertNewObjectForEntityForName:@"GITTask" inManagedObjectContext:self.context];
    }
    [task setTitle:title];
    [task setStart_time:start];
    [task setEnd_time:end];
    [task setBelongsTo:category];
    [task setDuration:duration];
    [task setEvent_description:description];                            //optional
    [task setDeadline:deadline];                                        //optional
    [task setPriority:priority];                                        //optional
    return [self saveContextSuccessful];
}

-(BOOL)makeCategoryWithTitle:(NSString *)name
{
    GITCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"GITCategory"  inManagedObjectContext:self.context];
    [category setTitle:name];
    return [self saveContextSuccessful];
}

-(void)makeTimeSlotTableForCategoryTitle:(NSString *)title
{
    GITCategory *category = [self fetchCategoryWithTitle:title];
    int timeSlotsMade = 0;
    for(int i = 0; i < 168; i++)
    {
        GITTimeSlot *timeSlot = [NSEntityDescription insertNewObjectForEntityForName:@"GITTimeSlot" inManagedObjectContext:self.context];
        if(i >= 0 && i < 24)
        {
            [timeSlot setDay_of_week:@"Monday"];
        }
        else if(i >= 24 && i < 48)
        {
            [timeSlot setDay_of_week:@"Tuesday"];
        }
        else if(i >= 48 && i < 72)
        {
            [timeSlot setDay_of_week:@"Wednesday"];
        }
        else if(i >= 72 && i < 96)
        {
            [timeSlot setDay_of_week:@"Thursday"];
        }
        else if(i >= 96 && i < 120)
        {
            [timeSlot setDay_of_week:@"Friday"];
        }
        else if(i >= 120 && i < 144)
        {
            [timeSlot setDay_of_week:@"Saturday"];
        }
        else if(i >= 144 && i < 168)
        {
            [timeSlot setDay_of_week:@"Sunday"];
        }
        [timeSlot setTime_of_day:[NSNumber numberWithInt:i%24]];
        //Inialize all weights as 0
        [timeSlot setWeight:[NSNumber numberWithInt:0]];
        [timeSlot setCorrespondsTo:category];
        timeSlotsMade++;
    }
    [self saveContextSuccessful];
}

-(void)changeWeightForTimeSlot:(GITTimeSlot *)timeSlot byAmount:(int)amount
{
    int currentWeightInt = [timeSlot.weight intValue];
    NSNumber *newWeight = [NSNumber numberWithInt:(currentWeightInt+amount)];
    [timeSlot setWeight:newWeight];
    [self saveContextSuccessful];
}


#pragma mark Alter entity methods

-(BOOL) deleteEventFromDatabase:(GITEvent *)event
{
    //Delete event
    [self.context deleteObject:event];
    
    // Commit the change.
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return false;
    }
    //If it was actually deleted from the database, return true
    else {
        return true;
    }
}

#pragma mark General fetch methods

/**
 Forms basic fetch request for event entity
 */
-(NSFetchRequest *) formEventFetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GITEvent" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    return fetchRequest;
}

/**
 Fetches all entities of type "Event" in the database.
 */
-(NSArray *) fetchAllEvents
{
    NSFetchRequest *fetchRequest = [self formEventFetchRequest];
    NSError *error;
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

-(NSArray *) fetchEventsOnDay:(NSDate *)day
{
    NSFetchRequest *fetchRequest = [self formEventFetchRequest];
    
    //Times square shows dateSelected as having time 4:00 am, must subtract 4 hours
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:@"gregorian"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:-4];
    day = [cal dateByAddingComponents:comps toDate:day  options:0];
    
    //End of date range will be 12:00 am of next day
    NSDate *endOfDateSelected = [day dateByAddingTimeInterval:(24*60*60)];
    
    //Form predicate to only get events in the specified date range
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"start_time <= %@ && start_time >= %@", endOfDateSelected, day];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"start_time" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

//Date will be a day in the month you want to find events for
-(NSArray *) fetchEventsInMonth:(NSDate *)date
{
    NSFetchRequest *fetchRequest = [self formEventFetchRequest];
    
    //Get month and year from passed in date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date]; // Get necessary date components
    int month = [components month];
    int year = [components year];
    
    //Make dates for first and last day of this month
    NSDate *startDate = [NSDate dateWithYear:year month:month weekday:0 day:1 hour:0 minutes:0 seconds:0];
    NSDate *endDate = [NSDate dateWithYear:year month:month weekday:0 day:31 hour:0 minutes:0 seconds:0];
    
    //Form predicate to only get events in the specified date range
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"start_time <= %@ && start_time >= %@", endDate, startDate];
    [fetchRequest setPredicate:predicate];
    //Sort results
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"start_time" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

-(GITCategory *) fetchCategoryWithTitle:(NSString *)title
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GITCategory" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    /*
     Since title must be unique, this will only return one object in the array, and that is the category we want
     */
    GITCategory *category = [fetchedObjects objectAtIndex:0];
    return category;
}

-(NSArray *)fetchEntitiesOfType:(NSString *)entityType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityType inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (GITTimeSlot *)fetchTimeSlotForDate:(NSDate *)date andCategoryTitle:(NSString *)categoryTitle
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"GITTimeSlot" inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    //Get day of week
    NSString *dayOfWeek = [NSDate dayOfWeekStringFromDate:date];
    
    //Get hour of day
    int hourOfDay = [NSDate militaryHourFromDate:date];
    
    // Set predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day_of_week = %@ && time_of_day = %d && correspondsTo.title = %@", dayOfWeek, hourOfDay, categoryTitle];
    [fetchRequest setPredicate:predicate];
    
    //Get time slot
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    //At this point, fetchedObjects should always only have one object
    return [fetchedObjects objectAtIndex:0];
}

- (NSArray *)fetchTimeSlotsOrderedByWeightForCategoryTitle:(NSString *)categoryTitle;
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"GITTimeSlot" inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"correspondsTo.title = %@", categoryTitle];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"weight" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    //TODO: I guess somehow check to make sure this is always consistent? eg if sunday at 5 and saturday at 5 have the same weight, make sure sunday at 5, if sorted first once, is always sorted first
    
    //Get time slot
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}


# pragma mark Fetch events with goal of checking something

- (BOOL)eventWithinDuration:(NSNumber *)duration startingAt:(NSDate *)rStart
{
    BOOL hasEvent = NO;
    int durationInt = [duration intValue];
    
    //In model, for now assuming duration in terms of minutes
    //dateByAddingTimeInterval is in seconds
    NSDate *rEnd = [rStart dateByAddingTimeInterval:(durationInt*60)];
    
    NSArray *fetchedObjects = [self fetchAllEvents];
    //Loop through database to check each event
    for(NSManagedObject *info in fetchedObjects)
    {
        NSDate *eStart = [info valueForKey:@"start_time"];
        NSDate *eEnd = [info valueForKey:@"end_time"];
        //Check for any overlap, excluding if one of the events ends when the other starts
        if([rStart compare:eEnd] == NSOrderedAscending &&
           [rEnd compare:eStart] == NSOrderedDescending)
        {
            hasEvent = YES;
        }
    }
    return hasEvent;
}

-(BOOL) checkIfEntityOfType:(NSString *)entityType existsWithName:(NSString *)title
{
    BOOL entityExists = NO;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityType inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entityDescription];
    
    // Set predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    //Loop through fetchedObjects to check for overlap
    for(NSManagedObject *info in fetchedObjects)
    {
        NSString *entityTitle = [info valueForKey:@"title"];
        if([entityTitle isEqualToString:title])
        {
            entityExists = YES;
        }
    }
    
    return entityExists;
}


# pragma mark General Helper methods

/**
 Saves the app's context and returns true if the save was successful
 */
- (BOOL) saveContextSuccessful
{
    BOOL success = YES;
    [(GITAppDelegate *)([UIApplication sharedApplication].delegate) saveContext];
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        success = NO;
    }
    return success;
}
@end
