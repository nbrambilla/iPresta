//
//  AppContactsListViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AppContactsListViewController.h"
#import "iPrestaNSString.h"
#import "AddressBookRegister.h"
#import "User.h"
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
    NSMutableArray *appContactsArray = [NSMutableArray new];
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    // Se crea un objeto agenda con todos los contactos existentes en el telefono. Se crea un arrray con la agenda para poder recorrerlo
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSInteger countPeople = ABAddressBookGetPersonCount(addressBook);
    
    
    // se recorre el array de la agenda. Se crean un arrary de AddressBookRegisters y de emails. Con toda la agenda
    for (NSInteger i = 0; i < countPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *middleName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSInteger countEmails = ABMultiValueGetCount(emails);
        
        for (NSInteger j = 0; j < countEmails; j++)
        {
            NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            
            AddressBookRegister *reg = [[AddressBookRegister alloc] initWithFirstName:firstName middleName:middleName lastName:lastName andEmail:email];
            [appContactsArray addObject:reg];
            [emailsArray addObject:email];
        }
    }
    
    // se crea una consulata para poder buscar todos los usuarios de la app de que tenemos en la agenda a partir del array de emils.
    PFQuery *appUsersQuery = [User query];
    [appUsersQuery whereKey:@"email" containedIn:emailsArray];
    [appUsersQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [appUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         [ProgressHUD hideHUDForView:self.view animated:YES];
        
         appContactsList = [NSMutableArray new];
        
         if (error) [error manageErrorTo:self];     // Si hay error al obtener los usuarios de la app
         else                                       // Si se obtienen los usuarios, se buscan en los registros
         {
             // se buscan las coincidencias en el array de AddressBookRegister para buscar los registros de los usuarios de la app. Si existe, no se debe mostrar el registro del usuario logueado
             for (User *user in objects)
             {
                 for (AddressBookRegister *reg in appContactsArray)
                 {
                     if ([user.email isEqual:reg.email] && ![user isEqual:[User currentUser]])
                     {
                         reg.user = user;
                         [appContactsList addObject:reg];
                     }
                 }
             }
             
             // Se ordenan los usuarios de la app por indice y orden alfabetico y se recarga la tabla para poder visualizarlos
             appContactsList = [[self partitionObjects:appContactsList collationStringSelector:@selector(firstLetter)] mutableCopy];
             [self.tableView reloadData];
         }
     }];
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
        for (AddressBookRegister *reg in section)
        {
            NSComparisonResult result = [[reg getFullName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[[reg getFullName] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
            if (result == NSOrderedSame)
            {
                [filteredAppContactsList addObject:reg];
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
    
    AddressBookRegister *reg;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        reg = [filteredAppContactsList objectAtIndex:indexPath.row];
    }
	else
	{
        reg = [[appContactsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [reg getFullName];
    cell.detailTextLabel.text = reg.email;
    
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddressBookRegister *reg;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        reg = [filteredAppContactsList objectAtIndex:indexPath.row];
    }
	else
	{
        reg = [[appContactsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [User setObjectsUser:reg.user];
    
    ObjectsMenuViewController *viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    reg = nil;
    viewController = nil;
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
    for (AddressBookRegister *reg in array)
    {
        NSInteger index = [collation sectionForObject:reg collationStringSelector:selector];
        
        [[unsortedSections objectAtIndex:index] addObject:reg];
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
