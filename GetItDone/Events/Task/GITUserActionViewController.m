//
//  GITUserActionViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 3/27/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITUserActionViewController.h"
//TODO  - Delete task that's postponed, then rescheduled?
@implementation GITUserActionViewController

#pragma mark -  Set up
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the date suggestion from the dictionary and save it to the property
    _dateSuggestion = [_taskInfoDictionary valueForKey:@"dateSuggestion"];
    
    // Set date suggestion label to show date suggestion generated on previous view
    [self setSuggestionLabelWithDateSuggestion];
}


// Display the date suggestion (using _dateSuggestion) by setting the text of the suggestion label
- (void)setSuggestionLabelWithDateSuggestion
{
    // Get start time as string
    NSString *startDateString = [self.formatter stringFromDate:_dateSuggestion];

    // Get the end time
    NSNumber *duration = [_taskInfoDictionary valueForKey:@"duration"];
    NSDate *endDate = [_dateSuggestion dateByAddingTimeInterval:(60*[duration intValue])];
    NSString *endDateString = [self.formatter stringFromDate:endDate];
    
    // Set the label text to be the suggestion
    NSString *labelText = [NSString stringWithFormat:@"Suggested start time for task:\n %@ \n \nSuggested end time for task:\n %@", startDateString, endDateString];
    [_labelSuggestion setText:labelText];
}

#pragma mark - Constructors

- (GITSmartSchedulingViewController *)smartScheduler
{
    if(!_smartScheduler)
    {
        _smartScheduler = [[GITSmartSchedulingViewController alloc] init];
    }
    return _smartScheduler;
}

-(NSDateFormatter *)formatter
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:kGITDefintionDateFormat];
    }
    return _formatter;
}

- (GITTaskManager *)taskManager
{
    if(!_taskManager)
    {
        _taskManager = [[GITTaskManager alloc] init];
    }
    return _taskManager;
}


# pragma mark - User Actions
- (IBAction)buttonPressedAccept:(id)sender
{
    NSString *title;
    NSString *description;
    NSNumber *duration;
    NSString *categoryTitle;
    NSDate *deadline;
    NSNumber *priority;
    GITTask *task;
    
    // If task already exists, use info from here
    if([_taskInfoDictionary valueForKey:@"task"])
    {
        task = [_taskInfoDictionary valueForKey:@"task"];
        title = task.title;
        description = task.event_description;
        duration = task.duration;
        categoryTitle = task.belongsTo.title;
        deadline = task.deadline;
        priority = task.priority;
    }
    
    // Otherwise, get info from dictionary
    else
    {
        title = [_taskInfoDictionary valueForKey:@"title"];
        description = [_taskInfoDictionary valueForKey:@"description"];
        duration = [_taskInfoDictionary valueForKey:@"duration"];
        categoryTitle = [_taskInfoDictionary valueForKey:@"categoryTitle"];
        deadline = [_taskInfoDictionary valueForKey:@"deadline"];
        priority = [_taskInfoDictionary valueForKey:@"priority"];
    }
    
    // Have TaskManager schedule task at suggested time
    GITTask *newTask = [self.taskManager makeTaskAndSaveWithTitle:title startDate:_dateSuggestion description:description duration:duration categoryTitle:categoryTitle deadline:deadline priority:priority forTask:task];
    
    if(newTask)
    {
        // Register accept with smart scheduler
        [self.smartScheduler userActionTaken:kGITUserActionAccept forTask:newTask];

        // Set root nav controller as rootViewController, then pop to its root vc
        //TODO HERM - This doesn't work if you're coming from manual time vc - gets rid of add task manually screen, but then you're just on user action vc

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kGITMainStoryboard bundle:nil];
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:kGITNavControllerRoot];
        self.view.window.rootViewController = nav;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Could not save task. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)buttonPressedReject:(id)sender
{
    NSString *title;
    NSNumber *duration;
    NSString *categoryTitle;
    
    // If task already exists, use info from here
    if([_taskInfoDictionary valueForKey:@"task"])
    {
        GITTask *task = [_taskInfoDictionary valueForKey:@"task"];
        title = task.title;
        duration = task.duration;
        categoryTitle = task.belongsTo.title;
    }
    // Otherwise, get info from dictionary
    else
    {
        title = [_taskInfoDictionary valueForKey:@"title"];
        duration = [_taskInfoDictionary valueForKey:@"duration"];
        categoryTitle = [_taskInfoDictionary valueForKey:@"categoryTitle"];
    }
    // Register reject with smart scheduler:
    [self.smartScheduler rejectionForTaskTitle:title categoryTitle:categoryTitle startTime:_dateSuggestion duration:duration];
 
    
    // Get new suggestion from smart scheduler
    NSDate *deadline = [_taskInfoDictionary valueForKey:@"deadline"];
    NSNumber *priority = [_taskInfoDictionary valueForKey:@"priority"];
    int dayPeriod = [self.taskManager getDayPeriodForTaskPriority:priority];
    _dateSuggestion = [self.smartScheduler makeTimeSuggestionForDuration:duration andCategoryTitle:categoryTitle withinDayPeriod:dayPeriod forDeadline:deadline];
    
    // Display new suggestion
    //TODO UI: - Make it more obvious that new suggestion generated!
    [self setSuggestionLabelWithDateSuggestion];
}

- (IBAction)buttonPressedManuallySchedule:(id)sender
{
    NSString *title;
    NSNumber *duration;
    NSString *categoryTitle;
    
    // If task already exists, use info from here
    if([_taskInfoDictionary valueForKey:@"task"])
    {
        GITTask *task = [_taskInfoDictionary valueForKey:@"task"];
        title = task.title;
        duration = task.duration;
        categoryTitle = task.belongsTo.title;
    }
    // Otherwise, get info from dictionary
    else
    {
        title = [_taskInfoDictionary valueForKey:@"title"];
        duration = [_taskInfoDictionary valueForKey:@"duration"];
        categoryTitle = [_taskInfoDictionary valueForKey:@"categoryTitle"];
    }
    
    // Register as reject with smart scheduler
    [self.smartScheduler rejectionForTaskTitle:title categoryTitle:categoryTitle startTime:_dateSuggestion duration:duration];
    
    // Send to ManualTaskViewController
    [self performSegueWithIdentifier:kGITSeguePushManualTask sender:self];
}

#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if([[segue identifier] isEqualToString:kGITSeguePushManualTask])
     {
         GITManualTaskViewController *vc = [segue destinationViewController];
         vc.delegate = self;
     }
}


#pragma mark - Manual task delegate

- (void)manualTaskViewController:(GITManualTaskViewController *)controller finishedWithStartTime:(NSDate *)start andEndTime:(NSDate *)end
{
    //Get duration and override what user entered
    double timeIntervalMinutes = ([end timeIntervalSinceDate:start] / 60);
    NSNumber *duration = [NSNumber numberWithDouble:timeIntervalMinutes];
    //TODO - Test
    [_taskInfoDictionary setObject:duration forKey:@"duration"];
    
    //Set date suggestion to be the user's chosen start date
    _dateSuggestion = start;
    
    //With the above member variables set, acceptSuggestion can handle adding the task
    [self buttonPressedAccept:self];
}


//TODO: Figure out if user trying to leave this screen for a task that is supposed to be currently happening! Eg postpone then tried to leave this screen
@end
