//
//  AppDelegate.h
//  GetItDone
//
//  Created by Amanda Jones on 8/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITTask.h"
#import "GITTaskManager.h"

@interface GITAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 NSManagedObjectContext for core data
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
/**
 NSManagedObjectModel for core data
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
/**
 Persistant Store Coordinator for core data
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
/**
 The entity manager for task
 */
@property (nonatomic, strong) GITTaskManager *taskManager;
/**
 The task in the notification
 */
@property (nonatomic, strong) GITTask *task;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end
