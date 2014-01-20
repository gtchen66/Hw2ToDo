//
//  ToDoTableViewController.m
//  Hw2ToDo
//
//  Created by George Chen on 1/17/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "ToDoTableViewController.h"
#import "ToDoCell.h"

#import <objc/runtime.h>

@interface ToDoTableViewController ()

@property (nonatomic, strong) NSMutableArray *arrayToDo;
@property (nonatomic, strong) NSString *pathToStorageFile;

@property (nonatomic, assign) BOOL editingCell;

-(void)saveArrayToDisk;

@end

@implementation ToDoTableViewController

// Global declaration -- why here and not above?
static char indexPathKey;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // NSLog(@"inside viewDidLoad");

    self.title = @"To Do List";
    
    // this path works with the simulator -- not sure what a real device path would look like.
    self.pathToStorageFile = @"/tmp/gtchenToDoFilePath.plist";

    UINib *customNib = [UINib nibWithNibName:@"ToDoCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"ToDoCell"];
    
    // set up initial left/right button on the navigation bar.  from the mock
    // the left button goes from "Edit" to "Done", so the later code should overwrite it
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(EditTable:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(AddEntryToTable:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    // initialize the ToDo array with data from the last execution.  if nil (file non-existent),
    // then create it.
    self.arrayToDo = [[NSMutableArray alloc]initWithContentsOfFile:self.pathToStorageFile];
    if (self.arrayToDo == nil) {
        self.arrayToDo = [[NSMutableArray alloc]init];
        NSLog(@"Starting from scratch with an empty list");
    }
    else {
        NSLog(@"Load previous data - %d entries",[self.arrayToDo count]);
    }
}

// call this function when the left button pressed.
//
- (IBAction)EditTable:(id)sender {
    NSLog(@"Editing table");
    // if editing, change left to Done, else it is Edit.
    if (self.tableView.editing) {
        // could also use [super setEditing:NO animated:NO]; but using more specific instead.
        [self.tableView setEditing:NO animated:NO];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else {
        // [super setEditing:YES animated:YES];
        // [self setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    [self.tableView reloadData];
}

// call this when right button (ADD) pressed
//
- (IBAction)AddEntryToTable:(id)sender {
    // Add a new entry.
    // open keyboard
    // new entry is at top
    
    // what is in position zero.  someone may have been editing just prior
    // to this call, so use reload to reset
    [self.tableView reloadData];
    NSLog(@"inside AddEntryToTable.  first todo is <%@>", [self.arrayToDo objectAtIndex:0]);

    [self.arrayToDo insertObject:@"" atIndex:0];
    [super setEditing:NO];
    [self.tableView reloadData];
    UITableViewCell *tvcell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    ToDoCell *cell = (ToDoCell* )((id)tvcell);
    
    UITextField *textField = cell.taskTextField;
    [textField becomeFirstResponder];
    
}

// for delete to work, need to have a commitEditingStyle
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"deleting object %d",indexPath.row);
        [self.arrayToDo removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];

        [self saveArrayToDisk];
        // write to file
//        if ([self.arrayToDo writeToFile:self.pathToStorageFile atomically:YES] == YES) {
//            NSLog(@"Wrote to file");
//        } else {
//            NSLog(@"Error writing to file");
//        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// user pressed Return.  Save the content before proceeding.
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"inside textFieldShouldReturn - text in cell is <%@>",textField.text);

    // Get the row for this cell.
    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
    
    NSLog(@".. updating row %d with <%@>", indexPath.row, textField.text);
    [self.arrayToDo replaceObjectAtIndex:indexPath.row withObject:textField.text];
    [self saveArrayToDisk];
    
    // get rid of keyboard.
    [self.view endEditing:YES];
    return YES;
}

// someone was editing, then clicked on another entry
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);

    NSLog(@"inside textFieldShouldEndEditing for row %d, <%@>", indexPath.row, textField.text);
    
    // save the content of this cell before proceeding.
    [self.arrayToDo replaceObjectAtIndex:indexPath.row withObject:textField.text];
    [self.tableView reloadData];
    
    return YES;
}

// To reorder the table, 2 methods needed: canEditRowAtIndexPath and moveRowAtIndexPath.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"moving from %d to %d",sourceIndexPath.row, destinationIndexPath.row);
    if (sourceIndexPath.row < destinationIndexPath.row) {
        [self.arrayToDo insertObject:[self.arrayToDo objectAtIndex:sourceIndexPath.row] atIndex:(destinationIndexPath.row + 1)];
        [self.arrayToDo removeObjectAtIndex:sourceIndexPath.row];
    }
    else {
        [self.arrayToDo insertObject:[self.arrayToDo objectAtIndex:sourceIndexPath.row] atIndex:destinationIndexPath.row];
        [self.arrayToDo removeObjectAtIndex:(sourceIndexPath.row + 1)];
    }
    [self.tableView reloadData];
    [self saveArrayToDisk];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arrayToDo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToDoCell";
    ToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSLog(@"cell was nil, so calling initWithStyle");
    }
    
    cell.taskTextField.delegate = self;
    cell.taskTextField.text = [self.arrayToDo objectAtIndex:indexPath.row];
    
    objc_setAssociatedObject(cell.taskTextField, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return cell;
}

- (void) saveArrayToDisk {
    // save the data here into a unix file.  where does this go on a device?
    if ([self.arrayToDo writeToFile:self.pathToStorageFile atomically:YES] == YES) {
        NSLog(@"Wrote to file");
    } else {
        NSLog(@"Error writing to file");
    }
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
