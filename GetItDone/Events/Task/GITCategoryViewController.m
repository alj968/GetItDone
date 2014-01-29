//
//  GITCategoryViewController.m
//  GetItDone
//
//  Created by Amanda Jones on 1/29/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "GITCategoryViewController.h"

@implementation GITCategoryViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(GITCategoryManager *)categoryManager
{
    if(!_categoryManager)
    {
        _categoryManager = [[GITCategoryManager alloc] init];
    }
    return _categoryManager;
}


 /**
 Sets list of category options, using categories stored in the database, plus the option to create a new category
 */
/*
-(void)setUpCategoryPicker
{
    //Ask category manager to get all categories
    _categoryOptionsArray = [[self.categoryManager getAllCategoryTitles] mutableCopy];
    
    //Add option to add a new category
    [_categoryOptionsArray addObject:@"Create New Category"];
    
    //In database set up, "None" is first category, and make this default selection
    [_pickerViewCategory selectRow:0 inComponent:0 animated:NO];
    
    //Set up label to have default selection displayed
    _labelCategory.text = @"None";
    _categoryTitle = @"None";
}
*/

/**
 Makes a new category with the given title.
 Sets the member variable of category title,
 calls the category manager ot create the category in the datbase,
 and adjusts the picker view for category accordingly
 */
/*
- (void)makeNewCategoryWithTitle:(NSString *)categoryTitle
{
    //Set member variable
    _categoryTitle = categoryTitle;
    
    //Make category via category manager
    [self.categoryManager addCategoryWithTitle:_categoryTitle];
    
    //Set up picker view
    [_categoryOptionsArray insertObject:_categoryTitle atIndex:(_categoryOptionsArray.count - 1)];
    [_pickerViewCategory reloadAllComponents];
    [_pickerViewPriority selectRow:(_categoryOptionsArray.count) inComponent:0 animated:NO];
}
 */
/*
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _pickerViewPriority)
    {
        //Low = 1, Medium = 2, High = 3
        _priority = [NSNumber numberWithInt:(row+1)];
        _labelPriority.text = [_priorityOptionsArray objectAtIndex:row];
    }
    //Category picker view
    else
    {
        NSString *chosenCategoryString = [_categoryOptionsArray objectAtIndex:row];
        
        if([chosenCategoryString isEqualToString:@"Create New Category"])
        {
            //If user selects create new category, then doesn't choose one, makes category "None"
            _categoryTitle = @"None";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kGITAlertNewCategory
                                                                message:@"Enter New Category Title"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        }
        else
        {
            _categoryTitle = chosenCategoryString;
        }
    }
}
*/

/**
 Handles the user accepting or rejecting smart scheduling suggestion
 *//*
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:kGITAlertTimeSuggestion])
    {
        if (buttonIndex == 1)
        {
            [self acceptSuggestion];
        }
        else if(buttonIndex == 2)
        {
            [self rejectSuggestion];
        }
    }
    else if([alertView.title isEqualToString:kGITAlertNewCategory])
    {
        //If category submitted
        if(buttonIndex == 1)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [self makeNewCategoryWithTitle:textField.text];
        }
    }
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
