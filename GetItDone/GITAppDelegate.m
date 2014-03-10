
//
//  AppDelegate.m
//  GetItDone
//
//  Created by Amanda Jones on 8/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "GITAppDelegate.h"
#import "MasterViewController.h"
#import "NSManagedObjectContext+FetchedObjectFromURI.h"
#import "GITSetUpDatabase.h"

@implementation GITAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (GITSmartSchedulingViewController *)smartScheduler
{
    if(!_smartScheduler)
    {
        _smartScheduler = [[GITSmartSchedulingViewController alloc] init];
    }
    return _smartScheduler;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GetItDone" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GetItDone.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         //TODO
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notifcation (at time of task) methods
//When app in background, this will get called from a notification's action item
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Determine if app launched from a notification
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(localNotification)
    {
        [self handleNotificationReceived:localNotification];
    }
    
    //Figure out if it's first launch or not
    [self determineVersion];
   
    return YES;
}

//When app in foreground, this will get called from a notification's action item
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)localNotification
{
    [self handleNotificationReceived:localNotification];
}

/**
 Using the version number and values int he NSUserDefaults dictionary, determines if this is the first launch of the app ever, if it's the first launch after upgrade/downgrade, or not the first launch
 */
-(void)determineVersion
{
    //Figure out if it's the first launch after install/upgrade/downgrade to handle importing events from other calendars
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"prevStartupVersions"];
    
    // Starting up for first time with NO pre-existing installs (e.g., fresh install of some version)
    if (prevStartupVersions == nil)
    {
        //Save current version
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:@"prevStartupVersions"];
        
        //Do first-launch tasks
        [self firstLaunchOfVersion:currentVersion];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            // Starting up for first time with this version of the app
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:@"prevStartupVersions"];
        }
    }
    
    // Save changes to disk
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 Sets up syncing and the database
 */
-(void)firstLaunchOfVersion:(NSString *)currentVersion
{
    //Set up syncing
    GITSyncingManager *syncingManager = [[GITSyncingManager alloc] init];
    [syncingManager setUpiCal];
    
    //Set up database
    GITSetUpDatabase *dbSetterUpper = [[GITSetUpDatabase alloc] init];
    [dbSetterUpper setUp];
}

/**
 Displays an alert asking user to "do" or "postpone" the task
 */
-(void)handleNotificationReceived:(UILocalNotification *)localNotification
{
    NSData *uriData = [localNotification.userInfo objectForKey:@"uriData"];
    NSURL *uri = [NSKeyedUnarchiver unarchiveObjectWithData:uriData];
    NSManagedObject *taskObj = [self.managedObjectContext objectWithURI:uri];
    _task = (GITTask *)taskObj;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ starts now.",_task.title] message:@"DO or POSTPONE task" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Postpone",@"Do", nil];
    [alert show];
}

//Let smart scheduler know if user postponed or did task
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Postpone touched
    if(buttonIndex == 0)
    {
        [self.smartScheduler userActionTaken:kGITUserActionPostpone forTask:_task];
        
    }
    //Do touched
    else if(buttonIndex == 1)
    {
        [self.smartScheduler userActionTaken:kGITUserActionDo forTask:_task];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

@end
