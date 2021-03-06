//
//  GITDatebaseHelper.m
//  GetItDone
//
//  Created by Amanda Jones on 9/25/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//
#import "GITDatabaseHelper.h"
#import "NSDate+Utilities.h"
#import <EventKit/EventKit.h>

@implementation GITDatabaseHelper

#pragma mark - Set up methods

-(NSManagedObjectContext *)context
{
    if(!_context)
    {
        _context = [(GITAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    }
    return _context;
}

#pragma mark - Create/edit entity methods

- (GITAppointment *) makeAppointmentAndSaveWithTitle:(NSString *)title
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
    if([self saveContextSuccessful])
    {
        return appointment;
    }
    else
    {
        return nil;
    }
}

- (GITTask *) makeTaskAndSaveWithTitle:(NSString *)title startDate:(NSDate *)start endDate:(NSDate *) end description:(NSString *)description duration:(NSNumber *)duration category:(GITCategory *)category deadline:(NSDate *)deadline priority:(NSNumber *)priority forTask:(GITTask *)task
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
    [task setPriority:priority];
    
    if([self saveContextSuccessful])
    {
        return task;
    }
    else
    {
        return nil;
    }
}

-(GITCategory *)makeCategoryWithTitle:(NSString *)name
{
    GITCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"GITCategory"  inManagedObjectContext:self.context];
    [category setTitle:name];
    if([self saveContextSuccessful])
    {
        return category;
    }
    else
    {
        return nil;
    }
}

-(void)makeTimeSlotTableForCategoryTitle:(NSString *)title
{
    GITCategory *category = [self fetchCategoryWithTitle:title];
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
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
        [timeSlotsArray addObject:timeSlot];
    }
    for (NSManagedObject *timeSlot in timeSlotsArray)
    {
        [self.context insertObject:timeSlot];
    }
    NSError *saveError = nil;
    [self.context save:&saveError];
}

-(void)changeWeightForTimeSlot:(GITTimeSlot *)timeSlot byAmount:(int)amount
{
    int32_t currentWeightInt = [timeSlot.weight integerValue];
    NSNumber *newWeight = [NSNumber numberWithInteger:currentWeightInt+amount];
    [timeSlot setWeight:newWeight];
    [self saveContextSuccessful];
}

-(void)increasePriorityForTask:(GITTask *)task;
{
    int currentPriority = [task.priority intValue];
    int newPriority = currentPriority;
    if(currentPriority == 1 || currentPriority == 2)
    {
        newPriority = newPriority + 1;
    }
    if(newPriority != currentPriority)
    {
        [task setPriority:[NSNumber numberWithInt:newPriority]];
        [self saveContextSuccessful];
    }
}

#pragma mark - Delete entity methods

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
    //If it was actually deleted from the database, delete notification and return true
    else {
        [self deleteNotificationsForEvent:event];
        return true;
    }
}

-(BOOL)deleteAlliCalendarEvents
{
    NSFetchRequest *alliCalendarEvents = [[NSFetchRequest alloc] init];
    [alliCalendarEvents setEntity:[NSEntityDescription entityForName:@"GITiCalendarEvent" inManagedObjectContext:self.context]];
    //Only fetch the managedObjectID
    [alliCalendarEvents setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *iCalendarEvents = [self.context executeFetchRequest:alliCalendarEvents error:&error];
    
    for (NSManagedObject *event in iCalendarEvents)
    {
        [self.context deleteObject:event];
    }
    NSError *saveError = nil;
    return [self.context save:&saveError];
}

-(void)deleteAlliCalendarEventsWithinMonths:(int)numberOfMonths
{
    // Get the date after which to start deleting events
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:numberOfMonths];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *deleteAfterDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    // Delete all events after deleteAfterDate, until following year
    // NOTE: this assumes the user opens the app once every two years.
    // The more often they often the app, the less events will get deleted each time this event is called
    
    NSDateComponents *dateComponents2 = [[NSDateComponents alloc] init];
    [dateComponents2 setYear:2];
    NSDate *endDate = [calendar dateByAddingComponents:dateComponents2 toDate:deleteAfterDate options:0];
    
    NSArray *oldEvents = [self fetchEventsInRangeFrom:deleteAfterDate until:endDate];
    for (NSManagedObject *event in oldEvents)
    {
        [self.context deleteObject:event];
    }
    NSError *saveError = nil;
    [self.context save:&saveError];
}

-(void)deleteNotificationsForEvent:(GITEvent *)event
{
    NSURL *uriToDelete = [[event objectID] URIRepresentation];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventNotifArray = [app scheduledLocalNotifications];
    
    for (int i=0; i< [eventNotifArray count]; i++)
    {
        UILocalNotification *oneEventNotif = [eventNotifArray objectAtIndex:i];
        NSDictionary *currentNotifDic = oneEventNotif.userInfo;
        NSData *uriData = [currentNotifDic objectForKey:@"uriData"];
        NSURL *uri = [NSKeyedUnarchiver unarchiveObjectWithData:uriData];
        
        if([uriToDelete isEqual:uri])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEventNotif];
        }
    }
}
-(BOOL)deleteCategoryFromDatabase:(GITCategory *)category
{
    //Delete category
    [self.context deleteObject:category];
    
    // Commit the change.
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return false;
    }
    //If it was actually deleted from the database, return true
    else
    {
        return true;
    }
}

#pragma mark - General fetch methods

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

-(NSArray *) fetchEventsInRangeFrom:(NSDate *)start until:(NSDate *)end
{
    NSFetchRequest *fetchRequest = [self formEventFetchRequest];
    
    
    //Form predicate to only get events in the specified date range
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"start_time <= %@ && start_time >= %@", end, start];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"start_time" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

-(NSArray *) fetchEventsOnDay:(NSDate *)day
{
    NSDate *startOfDateSelected = [NSDate dateAtBeginningOfDate:day];
    NSDate *endOfDateSelected = [NSDate dateAtEndOfDate:day];
    
    return [self fetchEventsInRangeFrom:startOfDateSelected until:endOfDateSelected];
}

//Date will be a day in the month you want to find events for
-(NSArray *) fetchEventsInMonth:(NSDate *)date
{
    //Get month and year from passed in date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date]; // Get necessary date components
    int month = [components month];
    int year = [components year];
    
    //Make dates for first and last day of this month
    NSDate *startDate = [NSDate dateWithYear:year month:month weekday:0 day:1 hour:0 minutes:0 seconds:0];
    NSDate *endDate = [NSDate dateWithYear:year month:month weekday:0 day:31 hour:0 minutes:0 seconds:0];
    
    return [self fetchEventsInRangeFrom:startDate until:endDate];
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
    if(fetchedObjects.count > 0)
    {
        GITCategory *category = [fetchedObjects objectAtIndex:0];
        return category;
        
    }
    else
    {
        return nil;
    }
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
    
    //Get time slot
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSArray *)fetchTasksInCategory:(NSString *)categoryTitle
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"GITTask" inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongsTo.title = %@", categoryTitle];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

# pragma mark - Fetch events with goal of checking something
/**
 Loops through database to see if any existing event's duration (excluding the given event) conflicts with the duration of
 the generated random event's duration. Returns NO if no conflict.
 @param duration Duration of the event, in minutes
 @param startTime The start of the date to check for overlap with.
 @param event The event that the event-to-be-scheduled can overlap with. This is important in the case of edit. (E.g. if an appointment was originally 8-9, and the user wants to make it 8:30-8:45, need to exclude the event in its original time from this overlap check so this edit is allowed).
 @return Returns NO if no overlapping event or if one event ends when another starts.
 Otherwise, returns YES.
 */
- (BOOL)overlapWithinDuration:(NSNumber *)duration startingAt:(NSDate *)startOfDate excludingEvent:(GITEvent *)event
{
    BOOL overlap = NO;
    int durationInt = [duration intValue];
    
    NSDate *endOfDate = [startOfDate dateByAddingTimeInterval:(durationInt*60)];
    
    //Start should be 12:00 am of day week before provided date
    NSDate *predicateStart = [NSDate dateAtBeginningOfDate:[startOfDate dateByAddingTimeInterval:60*60*24*-7]];
    //End should be 12:00 am of one week + one day after the day of the provided date
    NSDate *predicateEnd = [NSDate dateAtEndOfDate:[startOfDate dateByAddingTimeInterval:60*60*24*7]];
    NSArray *fetchedObjects = [self fetchEventsInRangeFrom:predicateStart until:predicateEnd];
    //Loop through database to check each event
    for(NSManagedObject *info in fetchedObjects)
    {
        if(info != event)
        {
            NSDate *thisEventStart = [info valueForKey:@"start_time"];
            NSDate *thisEventEnd = [info valueForKey:@"end_time"];
            //Check for any overlap, excluding if one of the events ends when the other starts
            if([startOfDate compare:thisEventEnd] == NSOrderedAscending &&
               [endOfDate compare:thisEventStart] == NSOrderedDescending)
            {
                overlap = YES;
            }
        }
    }
    return overlap;
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

# pragma mark - General Helper methods

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

#pragma mark - Private Methods

-(BOOL) deleteAllEvents
{
    BOOL allDeleted = true;
    if(![self deleteAllObjectsOfType:@"GITEvent"])
    {
        allDeleted = false;
    }
    return allDeleted;
}

-(BOOL) deleteAllCategoriesAndTimeSlots
{
    BOOL allDeleted = true;
    if(![self deleteAllObjectsOfType:@"GITCategory"])
    {
        allDeleted = false;
    }
    if(![self deleteAllObjectsOfType:@"GITTimeSlot"])
    {
        allDeleted = false;
    }
    return allDeleted;
}

- (BOOL)deleteAllObjectsOfType:(NSString *)entityDescription
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [self.context deleteObject:managedObject];
    }
    if (![self.context save:&error]) {
        return false;
    }
    else
    {
        return true;
    }
}

/**
 Makes a time slot with the given category title, day of week and hour. Makes the weight 0
 */
-(GITTimeSlot *)addTimeSlotWithCategoryTitle:(NSString *)categoryTitle dayOfWeek:(NSString *)dayOfWeek hour:(NSNumber *)hour
{
    GITCategory *category = [self fetchCategoryWithTitle:categoryTitle];
    GITTimeSlot *timeSlot = [NSEntityDescription insertNewObjectForEntityForName:@"GITTimeSlot" inManagedObjectContext:self.context];
    [timeSlot setDay_of_week:dayOfWeek];
    [timeSlot setTime_of_day:hour];
    [timeSlot setWeight:[NSNumber numberWithInt:0]];
    [timeSlot setCorrespondsTo:category];
    if([self saveContextSuccessful])
    {
        return timeSlot;
    }
    else
    {
        return nil;
    }
}

@end
