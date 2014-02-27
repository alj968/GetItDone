//
//  NSManagedObjectContext+FetchedObjectFromURI.h
//  GetItDone
//
//  Created by Amanda Jones on 2/26/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (FetchedObjectFromURI)

/**
 Returnts the object associated with the given uri. If not found, returns nil.
 */
- (NSManagedObject *)objectWithURI:(NSURL *)uri;

@end
