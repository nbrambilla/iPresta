//
//  AppContactsListViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AppContactsListViewController.h"
#import "iPrestaNSString.h"
#import "FriendIP.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ObjectsMenuViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AppContactsListViewController ()

@end

@implementation AppContactsListViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTableView) name:@"setFriendsObserver" object:nil];
    [self setTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UserIP setDelegate:self];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    appContactsList = nil;
    filteredAppContactsList = nil;
    searchBar = nil;
    
    [super viewDidUnload];
}

- (void)setTableView
{
    appContactsList = [[FriendIP getAll] copy];
    appContactsList = [[self partitionObjects:appContactsList collationStringSelector:@selector(firstLetter)] mutableCopy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[filteredAppContactsList removeAllObjects];
    
    for (NSArray *section in appContactsList)
    {
        for (FriendIP *friend in section)
        {
            NSComparisonResult result = [[friend getFullName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[[friend getFullName] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
            if (result == NSOrderedSame)
            {
                [filteredAppContactsList addObject:friend];
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return  nil;
    }
    else
    {
        BOOL showSection = [[appContactsList objectAtIndex:section] count] != 0;
    
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
        return [filteredAppContactsList count];
    }
    else
    {
        return [[appContactsList objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FriendIP *friend;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        friend = [filteredAppContactsList objectAtIndex:indexPath.row];
    }
	else
	{
        friend = [[appContactsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [friend getFullName];
    cell.detailTextLabel.text = friend.email;
    
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
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FriendIP *friend;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        friend = [filteredAppContactsList objectAtIndex:indexPath.row];
    }
	else
	{
        friend = [[appContactsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [UserIP getDBUserWithEmail:friend.email];
}

- (void)getDBUserWithEmailSuccess:(PFUser *)user withError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];
    else
    {
        [UserIP setObjectsUser:user];
        ObjectsMenuViewController *viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController = nil;
    }
}

# pragma mark - Private Methods

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for (int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (FriendIP *friend in array)
    {
        NSInteger index = [collation sectionForObject:friend collationStringSelector:selector];
        
        [[unsortedSections objectAtIndex:index] addObject:friend];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:@selector(getCompareName)] mutableCopy]];
    }
    
    return sections;
}

@end
