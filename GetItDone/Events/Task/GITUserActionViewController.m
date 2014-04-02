//
//  GITUserActionViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 3/27/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITUserActionViewController.h"
#import "GITSmartScheduler.h"

@implementation GITUserActionViewController

#pragma mark -  Set up
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the date suggestion from the dictionary and save it to the property
    _dateSuggestion = [_taskInfoDictionary valueForKey:@"dateSuggestion"];
    
    // Set date suggestion label to show date suggestion generated on previous view
    [self setSuggestionLabelWithDateSuggestion];
    
    self.delegate = [GITSmartScheduler sharedScheduler];
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
    
    // Transition to highlight date change
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_labelSuggestion.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    // Change the text
    [_labelSuggestion setText:labelText];
}

#pragma mark - Constructors

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
    
    // If task already exists, use task from here
    // This is the case if coming here from postponed task, or from getting new suggestion for edited task
    if([_taskInfoDictionary valueForKey:@"task"])
    {
        task = [_taskInfoDictionary valueForKey:@"task"];
    }
    // Only won't have value for title if from postponed task, so get rest of values from that task
    if(![_taskInfoDictionary valueForKey:@"title"])
    {
        title = task.title;
        description = task.event_description;
        duration = task.duration;
        categoryTitle = task.belongsTo.title;
        deadline = task.deadline;
        priority = task.priority;
    }
    // Otherwise, get info from dictionary
    // NOTE: Important to use this in case of edit so that most recent info is used
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
        //Send task to AddTaskViewController (which will dimiss modal view)
        if(self.delegate && [self.delegate respondsToSelector:@selector(userActionViewController:finishedWithAcceptForTask:)])
        {
            [self.delegate userActionViewController:self finishedWithAcceptForTask:newTask];
        }
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
    
    // Register reject with smart scheduler
    if(self.delegate && [self.delegate respondsToSelector:@selector(userActionViewController:finishedWithRejectForTaskTitle:categoryTitle:startTime:duration:)])
    {
        [self.delegate userActionViewController:self finishedWithRejectForTaskTitle:title categoryTitle:categoryTitle startTime:_dateSuggestion duration:duration];
    }
    
    // Get new suggestion from smart scheduler
    NSDate *deadline = [_taskInfoDictionary valueForKey:@"deadline"];
    NSNumber *priority = [_taskInfoDictionary valueForKey:@"priority"];
    int dayPeriod = [self.taskManager getDayPeriodForTaskPriority:priority];
    _dateSuggestion = [[GITSmartScheduler sharedScheduler] makeTimeSuggestionForDuration:duration andCategoryTitle:categoryTitle withinDayPeriod:dayPeriod forDeadline:deadline];
    
    // Display new suggestion
    [self setSuggestionLabelWithDateSuggestion];
}

- (IBAction)buttonPressedManuallySchedule:(id)sender
{
    NSString *title;
    NSNumber *duration;
    NSString *categoryTitle;
    
    GITTask *task;
    if([_taskInfoDictionary valueForKey:@"task"])
    {
        task = [_taskInfoDictionary valueForKey:@"task"];
    }
    // Only won't have value for title if from postponed task, so get rest of values from that task
    if(![_taskInfoDictionary valueForKey:@"title"])
    {
        title = task.title;
        duration = task.duration;
        categoryTitle = task.belongsTo.title;
    }
    // Otherwise, get info from dictionary
    // NOTE: Important to use this in case of edit so that most recent info is used
    else
    {
        title = [_taskInfoDictionary valueForKey:@"title"];
        duration = [_taskInfoDictionary valueForKey:@"duration"];
        categoryTitle = [_taskInfoDictionary valueForKey:@"categoryTitle"];
    }
    // Register as reject with smart scheduler
    if(self.delegate && [self.delegate respondsToSelector:@selector(userActionViewController:finishedWithRejectForTaskTitle:categoryTitle:startTime:duration:)])
    {
        [self.delegate userActionViewController:self finishedWithRejectForTaskTitle:title categoryTitle:categoryTitle startTime:_dateSuggestion duration:duration];
    }
    
    // Send to ManualTaskViewController
    [self performSegueWithIdentifier:kGITSeguePushManualTask sender:self];
}

#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:kGITSeguePushManualTask])
    {
        GITManualTaskViewController *vc = [segue destinationViewController];
        vc.editedTask = _editedTask;
        vc.delegate = self;
    }
}


#pragma mark - Manual task delegate

- (void)manualTaskViewController:(GITManualTaskViewController *)controller finishedWithStartTime:(NSDate *)start andEndTime:(NSDate *)end
{
    //Get duration and override what user entered
    double timeIntervalMinutes = ([end timeIntervalSinceDate:start] / 60);
    NSNumber *duration = [NSNumber numberWithDouble:timeIntervalMinutes];
    [_taskInfoDictionary setObject:duration forKey:@"duration"];
    
    //Set date suggestion to be the user's chosen start date
    _dateSuggestion = start;
    
    //With the above member variables set, acceptSuggestion can handle adding the task
    [self buttonPressedAccept:self];
}

#pragma mark - Cancel button

- (IBAction)buttonPressedCancel:(id)sender {
    if(_taskHappening)
    {
        _currentTask = [_taskInfoDictionary objectForKey:@"task"];
        
        //Display alert asking using to abandon task, or stay on this screen
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You've already postponed this task. Please reschedule the task, or abandon it." delegate:self cancelButtonTitle:@"Reschedule" otherButtonTitles:@"Abandon", nil];
        [alert show];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //If it's the alert from cancel
    if([alertView.title isEqualToString:@"Oops!"])
    {
        //buttonIndex = 0  means they want to reschedule, so stay on this screen
        //buttonIndex = 1 means they want to abandon task
        if(buttonIndex == 1)
        {
            // Abandon task
            GITDatabaseHelper *dbHelper = [[GITDatabaseHelper alloc] init];
            BOOL eventDeleted = [dbHelper deleteEventFromDatabase:_currentTask];
            if(!eventDeleted)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Deletion Failed"
                                                               message: @"Could not delete event. Please try again."
                                                              delegate: self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                [alert show];
            }
            
            
            // Go back to home screen
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

@end
