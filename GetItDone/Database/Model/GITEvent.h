//
//  GITEvent.h
//  GetItDone
//
//  Created by Amanda Jones on 3/5/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GITEvent : NSManagedObject

@property (nonatomic, retain) NSDate * end_time;
@property (nonatomic, retain) NSString * event_description;
@property (nonatomic, retain) NSNumber * in_app_event;
@property (nonatomic, retain) NSDate * start_time;
@property (nonatomic, retain) NSString * title;

@end
