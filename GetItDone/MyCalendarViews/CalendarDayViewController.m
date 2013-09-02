//
//  CalendarDayViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 8/11/13.
//  Copyright (c) 2013 Amanda Jones. All rights reserved.
//

#import "CalendarDayViewController.h"
#import "AppDelegate.h"

@implementation CalendarDayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //TODO: Style here
    }
    return self;
}

-(void)setEventsForToday:(NSArray *)eventArray
{
    events = eventArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set up table view content
    //TODO: Change this to all hours of the day
    /*
	times = [[NSMutableArray alloc] initWithObjects:@"8:00 am", @"9:00 am", @"10:00 am", @"11:00 am", @"12:00 pm", @"1:00 pm", @"2:00 pm",@"3:00 pm",@"4:00 pm",@"5:00 pm",@"6:00 pm",@"7:00 pm",@"8:00 pm",@"9:00 pm",
              nil];
    */
    self.title = @"Events";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [times count];
    return [events count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Event *event = [events objectAtIndex:indexPath.row];
    
    cell.textLabel.text = event.title;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE, MMMM d, YYYY"];
    NSString *dateString = [dateFormat stringFromDate:event.start_time];
    cell.detailTextLabel.text = dateString;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        //TODO: If that time slot has an event, show event details when the time row is clicked
    }
}



@end
