//
//  GITTimeSlotTableViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 1/16/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITTimeSlotTableViewController.h"

@implementation GITTimeSlotTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _timeSlots = [self.helper fetchEntitiesOfType:@"GITTimeSlot"];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weight"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    _timeSlots = [[_timeSlots sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (GITDatabaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatabaseHelper alloc] init];
    }
    return _helper;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _timeSlots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Time Slot Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    GITTimeSlot *timeSlot = [_timeSlots objectAtIndex:indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", timeSlot.day_of_week, timeSlot.time_of_day];
  //  cell.detailTextLabel.text = [timeSlot.weight stringValue];
    return cell;
}

@end
