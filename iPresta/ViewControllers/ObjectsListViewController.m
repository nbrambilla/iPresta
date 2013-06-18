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

#define HEADER_HEIGHT 44

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
    
    
    filteredObjectsArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTableView) name:@"setObjectsTableObserver" object:nil];
    
    [self setTableView];
    [self setTableViewHeader];
    [self setNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, HEADER_HEIGHT * 2) animated:NO];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController)
    {
        [iPrestaObject setTypeSelected:NoneType];
        [[User currentUser] setObjectsArray:nil];
    }
    
    [super viewWillDisappear:animated];
}

- (void)objectStateList:(id)sender
{
    [self.tableView reloadData];
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
             [[User currentUser] setObjectsArray:[NSMutableArray arrayWithArray:[self partitionObjects:objects collationStringSelector:@selector(firstLetter)]]];
             [self.tableView reloadData];
             [self.searchDisplayController.searchResultsTableView reloadData];
         }
     }];
}

- (void)setTableViewHeader
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, 320, HEADER_HEIGHT)];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Todos", @"No Prestados", @"Prestados", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.frame = CGRectMake(35, 200, 230, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(objectStateList:) forControlEvents:UIControlEventValueChanged];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.titleView = segmentedControl;
    
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT*2)];
    
    self.tableView.tableHeaderView = headerView;
    
    [headerView addSubview:searchBar];
    [headerView addSubview:navigationBar];
    
    self.navigationController.delegate = self;
}

- (void)setNavigationBar
{
    self.title = [[iPrestaObject objectTypes] objectAtIndex:[iPrestaObject typeSelected]];
    
    UIBarButtonItem *addObjectlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(goToAddObject)];
    self.navigationItem.rightBarButtonItem = addObjectlButton;
    
    addObjectlButton = nil;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tableView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add / Delete Object Methods

- (void)deleteObjectWithIndexPath:(NSIndexPath *)indexPath fromArray:(NSMutableArray *)array
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    iPrestaObject *object = nil;
    
    if (array == filteredObjectsArray)
	{
        object = [filteredObjectsArray objectAtIndex:indexPath.row];
    }
	else
	{
        object = [[[[User currentUser] objectsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];     // Si hay error al eliminar el objeto
         else                                       // Si se elimina el objeto, se actualiza la lista
         {
             PFQuery *getObjectsQuery = [Give query];
             [getObjectsQuery whereKey:@"object" equalTo:object];
             
             [getObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *gives, NSError *error)
             {
                 if (error) [error manageErrorTo:self];     // Si hay error al buscar los prestamos del objeto
                 else                                       // Si se encuentran los pretamos del objeto, se eliminan
                 {
                     for (Give *give in gives)
                     {
                         [give deleteInBackground];
                     }
                 }
             }];
             
             if (array == filteredObjectsArray)
             {
                 [filteredObjectsArray removeObjectAtIndex:indexPath.row];
                 [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             }
        
             NSInteger sectionIndex = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(firstLetter)];
             NSInteger objectIndex = [[[[User currentUser] objectsArray] objectAtIndex:sectionIndex] indexOfObject:object];
             [[[[User currentUser] objectsArray] objectAtIndex:sectionIndex] removeObjectIdenticalTo:object];
             
             NSIndexPath *tableViewIndexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
             [self.tableView deleteRowsAtIndexPaths:@[tableViewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
             
             tableViewIndexPath = nil;
         }
    }];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[filteredObjectsArray removeAllObjects];
    
    for (NSArray *section in [[User currentUser] objectsArray])
    {
        for (iPrestaObject *object in section)
        {
            NSComparisonResult result = [object.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[object.name rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
            if (result == NSOrderedSame)
            {
                [filteredObjectsArray addObject:object];
            }
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

#pragma mark - Change ViewController Methods

- (void)goToAddObject
{
    AddObjectViewController *viewController = [[AddObjectViewController alloc] initWithNibName:@"AddObjectViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
}

- (void)goToObjectDetail:(iPrestaObject *)object
{
    ObjectDetailViewController *objectDetailViewController = [[ObjectDetailViewController alloc] initWithNibName:@"ObjectDetailViewController" bundle:nil];
    
    [iPrestaObject setCurrentObject:object];
    
    [self.navigationController pushViewController:objectDetailViewController animated:YES];
    
    objectDetailViewController = nil;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return  nil;
    }
    else
    {
        BOOL showSection;
        NSArray *sectionArray = [[NSArray alloc] initWithArray:[[[User currentUser] objectsArray] objectAtIndex:section]];
        switch (segmentedControl.selectedSegmentIndex)
        {
            case 0:
                showSection = [sectionArray count] != 0;
                break;
            case 1:
                showSection = [[self getObjectsInState:Property inArray:sectionArray] count] != 0;
                break;
            case 2:
                showSection = [[self getObjectsInState:Given inArray:sectionArray] count] != 0;
                break;
        }
        
        return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return nil;
    }
    else
    {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 0;
    }
    else
    {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
    else
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    }    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredObjectsArray count];
    }
    else
    {
        NSArray *sectionArray = [[NSArray alloc] initWithArray:[[[User currentUser] objectsArray] objectAtIndex:section]];
        switch (segmentedControl.selectedSegmentIndex)
        {
            case 0:
                return [sectionArray count];
                break;
            case 1:
                return [self countObjectsInState:Property inArray:sectionArray];
                break;
            case 2:
                return [self countObjectsInState:Given inArray:sectionArray];
                break;
            default:
                return 0;
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexPath.row;
    iPrestaObject *object = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        object = [filteredObjectsArray objectAtIndex:indexPath.row];
    }
	else
	{
        NSArray *sectionArray = [[[User currentUser] objectsArray] objectAtIndex:indexPath.section];
        switch (segmentedControl.selectedSegmentIndex)
        {
            case 0:
                object = [sectionArray objectAtIndex:indexPath.row];
                break;
            case 1:
                object = [[self getObjectsInState:Property inArray:sectionArray] objectAtIndex:indexPath.row];
                break;
            case 2:
                object = [[self getObjectsInState:Given inArray:sectionArray] objectAtIndex:indexPath.row];
                break;
        }
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
                object.imageData = [[NSData alloc] initWithData:data];
                UIImage* image = [UIImage imageWithData:data];
                if (image)
                {
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        if (cell.tag == indexPath.row)
                        {
                            cell.imageView.image = image;
                            [cell setNeedsLayout];
                        }
                    });
                }
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
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [self deleteObjectWithIndexPath:indexPath fromArray:filteredObjectsArray];
        }
        else
        {
            [self deleteObjectWithIndexPath:indexPath fromArray:[[User currentUser] objectsArray]];
        }
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        [self goToObjectDetail:[filteredObjectsArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [self goToObjectDetail:[[[[User currentUser] objectsArray] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
}

# pragma mark - Private Methods

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector

{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (iPrestaObject *object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:selector] mutableCopy]];
    }
    
    return sections;
}

- (NSInteger)countObjectsInState:(ObjectState)state inArray:(NSArray *)array
{
    NSInteger count = 0;
    for (iPrestaObject *object in array)
    {
        if (object.state == state) count++;
    }
    return count;
}

- (NSMutableArray *)getObjectsInState:(ObjectState)state inArray:(NSArray *)array
{
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (iPrestaObject *object in array)
    {
        if (object.state == state) [filteredArray addObject:object];
    }
    return filteredArray;
}

@end
