//
//  GITEventViewController.h
//  GetItDone
//
//  Created by Amanda Jones on 3/12/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <EventKitUI/EventKitUI.h>
#import "GITCalendarViewController.h"

/**
 Subclass of EKEventViewController so I can customize the EKEventEditViewDelegate's method
 */
@interface GITEventViewController : EKEventViewController <EKEventEditViewDelegate>

@end
