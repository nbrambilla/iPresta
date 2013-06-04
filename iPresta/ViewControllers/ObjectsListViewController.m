//
//  ObjectsListViewController.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ObjectsListViewController.h"
#import "AddObjectViewController.h"
#import "ObjectDetailViewController.h"
#import "iPrestaObject.h"
#import "User.h"
#import "Give.h"

@interface ObjectsListViewController ()

@end

@implementation ObjectsListViewController

#pragma mark - Lifecycle Methods

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }      
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [[iPrestaObject objectTypes] objectAtIndex:[iPrestaObject typeSelected]];
    
    UIBarButtonItem *addObjectlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(goToAddObject)];
    self.navigationItem.rightBarButtonItem = addObjectlButton;
    
    addObjectlButton = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTableView) name:@"setObjectsTableObserver" object:nil];
    
    [self setTableView];
}

- (void)setTableView
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *getObjectsQuery = [iPrestaObject query];
    [getObjectsQuery whereKey:@"owner" equalTo:[User currentUser]];
    [getObjectsQuery whereKey:@"type" equalTo:[NSNumber numberWithInteger:[iPrestaObject typeSelected]]];
    
    [getObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];          // Si hay error al obtener los objetos
         else                                            // Si se obtienen los objetos, se listan
         {
             objects = [objects sortedArrayUsingComparator:^NSComparisonResult(iPrestaObject *a, iPrestaObject *b) {
                 NSString *first = a.name;
                 NSString *second = b.name;
                 return [first compare:second];
             }];
             
             objectsArray = [objects mutableCopy];
             [self.tableView reloadData];
             [self.searchDisplayController.searchResultsTableView reloadData];
                 
         }
     }];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    searchBar = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add / Delete Object Methods

- (void)deleteObjectWithIndex:(NSIndexPath *)indexPath fromArray:(NSMutableArray *)array
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    iPrestaObject *object = [array objectAtIndex:indexPath.row];
    
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];     // Si hay error al eliminar el objeto
         else                                       // Si se elimina el objeto, se actualiza la lista
         {
             if (array == filteredObjectsArray)
             {
                 [filteredObjectsArray removeObjectAtIndex:indexPath.row];
                 [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 
                 NSIndexPath *auxIndexPath = [NSIndexPath indexPathForRow:[objectsArray indexOfObject:object] inSection:0];
                 [objectsArray removeObjectIdenticalTo:object];
                 [self.tableView deleteRowsAtIndexPaths:@[auxIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                 
                 auxIndexPath = nil;
             }
             else
             {
                 [objectsArray removeObjectAtIndex:indexPath.row];
                 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             }
         }
    }];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	// Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	[filteredObjectsArray removeAllObjects];
    
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    NSArray *tempArray = [objectsArray filteredArrayUsingPredicate:predicate];
    
    filteredObjectsArray = [NSMutableArray arrayWithArray:tempArray];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark - Change ViewController Methods

- (void)goToAddObject
{
    AddObjectViewController *addObjectViewController = [[AddObjectViewController alloc] initWithNibName:@"AddObjectViewController" bundle:nil];
    [self.navigationController pushViewController:addObjectViewController animated:YES];
    
    addObjectViewController = nil;
}

- (void)goToObjectDetail:(iPrestaObject *)object
{
    ObjectDetailViewController *objectDetailViewController = [[ObjectDetailViewController alloc] initWithNibName:@"ObjectDetailViewController" bundle:nil];
    
    [iPrestaObject setCurrentObject:object];
    
    [self.navigationController pushViewController:objectDetailViewController animated:YES];
    
    objectDetailViewController = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [[self selectedArray:tableView] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    iPrestaObject *object = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        object = [filteredObjectsArray objectAtIndex:[indexPath row]];
    }
	else
	{
        object = [objectsArray objectAtIndex:[indexPath row]];
    }
    
    cell.textLabel.text = object.name;
    cell.detailTextLabel.text = [object textState];
    
    if (!object.imageData)
    {
        cell.imageView.image = [UIImage imageNamed:@"camera_icon.png"];
        
        [object.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                object.imageData = data;
                cell.imageView.image = [UIImage imageWithData:object.imageData];
            }
        }];
    }
    else
    {
        cell.imageView.image = [UIImage imageWithData:object.imageData];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteObjectWithIndex:indexPath fromArray:[self selectedArray:tableView]];

    }  
}

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
    
    [self goToObjectDetail:[[self selectedArray:tableView] objectAtIndex:indexPath.row]];
    
}

# pragma mark - Private Methods

- (NSMutableArray *)selectedArray:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return filteredObjectsArray;
    }
	else
	{
        return objectsArray;
    }
}

@end
