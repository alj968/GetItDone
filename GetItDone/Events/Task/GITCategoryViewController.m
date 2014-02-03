//
//  GITCategoryViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 1/29/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITCategoryViewController.h"
#import "GITButtonCell.h"

@implementation GITCategoryViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCategories];
}

-(GITCategoryManager *)categoryManager
{
    if(!_categoryManager)
    {
        _categoryManager = [[GITCategoryManager alloc] init];
    }
    return _categoryManager;
}

- (GITDatebaseHelper *)helper
{
    if(!_helper)
    {
        _helper = [[GITDatebaseHelper alloc] init];
    }
    return _helper;
}

/**
 Sets list of category options using categories stored in the database
 */
- (void)setUpCategories
{
    //Ask category manager to get all categories
    _categoryOptionsArray = [[self.categoryManager getAllCategoryTitles] mutableCopy];
}

- (void)buttonPressedAddCategory:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kGITAlertNewCategory
                                                        message:@"Enter New Category Title"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

/**
 Handles the user's actions on the add new category alert
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:kGITAlertNewCategory])
    {
        //If category submitted
        if(buttonIndex == 1)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            if(textField.text.length > 0)
            {
                [self makeNewCategoryWithTitle:textField.text];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Must enter a title for the new category" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

/**
 Makes a new category with the given title.
 Sets the member variable of category title,
 calls the category manager ot create the category in the datbase,
 and adjusts the table view for category accordingly
 */
- (void)makeNewCategoryWithTitle:(NSString *)categoryTitle
{
    //Pass error by reference
    NSError *validationError;
    //Make category via category manager
    BOOL success = [self.categoryManager addCategoryWithTitle:categoryTitle error:&validationError];

    if(!success)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:validationError.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //Add new category to array
        [_categoryOptionsArray addObject:categoryTitle];
        
        //Reload table
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return _categoryOptionsArray.count;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSString *categoryTitle = [_categoryOptionsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = categoryTitle;
    }
    else
    {
        static NSString *ButtonCellIdentifier = @"ButtonCell";
        GITButtonCell *buttonCell = (GITButtonCell *)[tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier forIndexPath:indexPath];
        [buttonCell.buttonAddCategory addTarget:self action:@selector(buttonPressedAddCategory:) forControlEvents:UIControlEventTouchUpInside];
        cell = buttonCell;
    }
    
    return cell;
}

/**
 Hides all lines below the end of the first section
 */
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), .5)];
    if(section == 0)
    {
        CGRect parentFrame = parentView.frame;
        CGRect childFrame = UIEdgeInsetsInsetRect(parentFrame, tableView.separatorInset);
        UIView *insetView = [[UIView alloc] initWithFrame:childFrame];
        parentView.backgroundColor = [UIColor clearColor];
        insetView.backgroundColor = tableView.separatorColor;
        [parentView addSubview:insetView];
    }
    return parentView;
}

//User chose a category, so pop them back to add task screen, and register the category title chosen
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _categoryTitle = [_categoryOptionsArray objectAtIndex:indexPath.row];

    if(self.delegate && [self.delegate respondsToSelector:@selector(categoryViewController:finishedWithCategoryTitle:)])
    {
        [self.delegate categoryViewController:self finishedWithCategoryTitle:_categoryTitle];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

//TODO: Think about if we want to allow user to delete cateogry with events - probably not!!! So would have to go through task manager to see if it can be deleted. And then would delete all references to helper
//Allow user to delete a category
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Use database helper to delete
        BOOL categoryDeleted = [self.helper deleteCategoryFromDatabase:[_categoryOptionsArray objectAtIndex:indexPath.row]];
        //If it was actually deleted from the database, delete from the array
        if(categoryDeleted)
        {
            // Update the array and table view.
            [_categoryOptionsArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            //TODO: FIGURE OUT if this is needed? [tableView reloadData];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Deletion Failed"
                                                           message: @"Could not delete category. Please try again."
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
}*/

@end
