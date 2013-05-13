//
//  ObjectsListViewController.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectsListViewController.h"
#import "AddObjectViewController.h"
#import "User.h"

@interface ObjectsListViewController ()

@end

@implementation ObjectsListViewController

@synthesize objectsArray;

#pragma mark - Lifecycle Methods

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Objetos";
    
    UIBarButtonItem *addObjectlButton = [[UIBarButtonItem alloc] initWithTitle:@"Agregar objeto" style:UIBarButtonItemStylePlain target:self action:@selector(goToAddObject)];
    self.navigationItem.rightBarButtonItem = addObjectlButton;
    
    addObjectlButton = nil;
    
    [iPrestaObject setDelegate:self];
    [iPrestaObject getObjectsFromUser:[User currentUser]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addObjectToList:) name:@"addObjectToListDelegate" object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Object List Methods

- (void)getObjectsFromUserSuccess:(NSArray *)result
{
    objectsArray = [result mutableCopy];
    [self.tableView reloadData];
}

- (void)addObjectToList:(NSNotification *)notification
{
    [objectsArray addObject:notification.object];
    [self.tableView reloadData];
}

#pragma mark - Change ViewController Methods

- (void)goToAddObject
{
    AddObjectViewController *addObjectViewController = [[AddObjectViewController alloc] initWithNibName:@"AddObjectViewController" bundle:nil];
    [self.navigationController pushViewController:addObjectViewController animated:YES];
    
    addObjectViewController = nil;
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
    return [objectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    iPrestaObject *object = [objectsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = object.name;
    cell.detailTextLabel.text = object.textType;
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
