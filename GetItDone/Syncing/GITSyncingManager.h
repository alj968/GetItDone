//
//  GITSyncWithiCal.h
//  GetItDone
//
//  Created by Amanda Jones on 3/3/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

//TODO: COMMENT WHOLE CLASS

@interface GITSyncingManager : NSObject

@property (nonatomic, strong) EKEventStore *eventStore;

-(void)setUp;

-(NSArray *)fetchEvents;

-(BOOL)deleteEventWithIdentifier:(NSString *)identifier;

@end
