//
//  AppDelegate.h
//  GetItDone
//
//  Created by Amanda Jones on 8/13/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITSmartSchedulingViewController.h"
#import "GITTask.h"
#import "GITSyncingManager.h"

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
 Smart scheduler to handle user actions from a user interacting with a local notification
 */
@property (strong, nonatomic) GITSmartSchedulingViewController *smartScheduler;
/**
 The task in the notification
 */
@property (nonatomic, strong) GITTask *task;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end
