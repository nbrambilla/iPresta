//
//  AppContactsListViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AppContactsListViewController.h"
#import "iPrestaNSString.h"
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

    [self setTableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    appContactsList = nil;
    filteredAppContactsList = nil;
    searchBar = nil;
    
    [super viewDidUnload];
}

- (void)setTableView
{
    filteredAppContactsList = [NSMutableArray new];
    appContactsList = [NSMutableArray arrayWithArray:[self partitionObjects:[self getAppContacts] collationStringSelector:@selector(firstLetter)]];
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
        for (NSString *object in section)
        {
            NSComparisonResult result = [object compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[object rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
            if (result == NSOrderedSame)
            {
                [filteredAppContactsList addObject:object];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        cell.textLabel.text = [filteredAppContactsList objectAtIndex:indexPath.row];
    }
	else
	{
        cell.textLabel.text = [[appContactsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
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

# pragma mark - Private Methods

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
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
    for (NSString *object in array)
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

- (NSMutableArray *)getAppContacts
{
    NSMutableArray *appContactsArray = [NSMutableArray new];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i = 0; i < nPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *fname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *name;
        NSString *phoneNumber;
        
        if (lname)
        {
            name = [fname stringByAppendingFormat: @" %@", lname];
        } else
        {
            name = fname;
        }
        
        ABMultiValueRef   phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        int count = ABMultiValueGetCount(phoneNumbers);
        
        if (count > 0 && name)
        {
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        }
        
        NSString *firstChar = [[name substringToIndex:1] lowercaseString];
        
        if ([firstChar isEqual:@"g"])
        {
            [appContactsArray addObject:name];;
        }
    }
    
    return appContactsArray;
}

@end
