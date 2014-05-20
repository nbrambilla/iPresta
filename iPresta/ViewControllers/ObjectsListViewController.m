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
#import "FormBookViewController.h"
#import "FormAudioViewController.h"
#import "FormVideoViewController.h"
#import "FormOtherViewController.h"
#import "ObjectDetailViewController.h"
#import "UserIP.h"
#import "ObjectCell.h"

#define HEADER_HEIGHT 44

@interface ObjectsListViewController ()

@end

@implementation ObjectsListViewController

#pragma mark - Lifecycle Methods

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
    
    [self addObservers];
    [self setTableView];
    [self setNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [ObjectIP setDelegate:self];
//    float offsetY = ([UserIP objectsUserIsSet]) ? HEADER_HEIGHT : HEADER_HEIGHT * 2;
//    
//    [tableView setContentOffset:CGPointMake(0, offsetY) animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ObjectIP setDelegate:nil];
    if (self.isMovingFromParentViewController) {
        objectsArray = nil;
        [ObjectIP setSelectedType:NoneType];
    }
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTableView) name:@"setObjectsTableObserver" object:nil];
}

- (void)objectStateList:(id)sender
{
    [tableView reloadData];
    noObjectsView.hidden = NO;
}

- (void)setTableView
{
    noObjectsLabel.text = IPString(@"No hay objetos");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    filteredObjectsArray = [NSMutableArray new];
    
    objectsArray = [ObjectIP getAllByType];
    
    if (![UserIP objectsUserIsSet])
    {
        [self reloadTables];
        [self setTableViewHeader];
    }
    else [ProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)getAllByTypeSuccess:(NSArray *)array
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    objectsArray = array;
    
    [self reloadTables];
}

- (void)objectError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    [error manageError];
}

- (void)setTableViewHeader
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, SCREEN_WIDTH, HEADER_HEIGHT)];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:@[IPString(@"Todos") , IPString(@"En casa"), IPString(@"Prestados")]];
    segmentedControl.frame = CGRectMake(35, 10, 300, 30);
//    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(objectStateList:) forControlEvents:UIControlEventValueChanged];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.titleView = segmentedControl;
    
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_HEIGHT * 2)];
    
    [headerView addSubview:searchBar];
    [headerView addSubview:navigationBar];
    [self.view addSubview:headerView];
    
    CGRect frame = tableView.frame;
    frame.origin.y = headerView.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    tableView.frame = frame;
    
    [tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

- (void)setNavigationBar
{
    self.title = OBJECT_TYPES[[ObjectIP selectedType]];
    
    if (![UserIP objectsUserIsSet])
    {
        UIBarButtonItem *addObjectlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(goToAddObject)];
        self.navigationItem.rightBarButtonItem = addObjectlButton;
        
        addObjectlButton = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add / Delete Object Methods

- (void)deleteObject
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ObjectIP *object = nil;
    
    if (selectedArray == filteredObjectsArray)
	{
        object = [filteredObjectsArray objectAtIndex:selectedIndexPath.row];
    }
	else
	{
        object = [[objectsArray objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row];
    }
    
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [object deleteObject];
}

- (void)deleteObjectSuccess:(ObjectIP *)object
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (selectedArray == filteredObjectsArray)
    {
        [filteredObjectsArray removeObjectAtIndex:selectedIndexPath.row];
        [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSInteger sectionIndex = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(firstLetter)];
    NSInteger objectIndex = [[objectsArray objectAtIndex:sectionIndex] indexOfObject:object];
    [[objectsArray objectAtIndex:sectionIndex] removeObjectIdenticalTo:object];
    
    NSIndexPath *tableViewIndexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
    [tableView deleteRowsAtIndexPaths:@[tableViewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:object.type, @"type", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DecrementObjectTypeObserver" object:options];
    options = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCountLabelsObserver" object:options];
    
    selectedIndexPath = nil;
    selectedArray = nil;
    tableViewIndexPath = nil;
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[filteredObjectsArray removeAllObjects];
    
    NSMutableArray *array = [self getObjectsAndSectionsArray];
    
    for (NSArray *section in array)
    {
        for (ObjectIP *object in section)
        {
            NSComparisonResult result = [object.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[object.name rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
            if (result == NSOrderedSame)
            {
                [filteredObjectsArray addObject:object];
            }
        }
    }
    
    array = nil;
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
    id viewController;
    
    switch ([ObjectIP selectedType])
    {
        case BookType:
            viewController = [[FormBookViewController alloc] initWithNibName:@"FormBookViewController" bundle:nil];
            break;
        case AudioType:
            viewController = [[FormAudioViewController alloc] initWithNibName:@"FormAudioViewController" bundle:nil];
            break;
        case VideoType:
            viewController = [[FormVideoViewController alloc] initWithNibName:@"FormVideoViewController" bundle:nil];
            break;
        case OtherType:
            viewController = [[FormOtherViewController alloc] initWithNibName:@"FormOtherViewController" bundle:nil];
            break;
        default:
            break;
    }

    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

- (void)goToObjectDetail:(ObjectIP *)object
{
    ObjectDetailViewController *viewController = [[ObjectDetailViewController alloc] initWithNibName:@"ObjectDetailViewController" bundle:nil];
    
    [ObjectIP setCurrentObject:object];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)_tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section

{
    if (_tableView == self.searchDisplayController.searchResultsTableView) return  nil;
    else
    {
        BOOL showSection = [[self getObjectsArrayInSection:section] count] != 0;
        
        return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)_tableView
{
    if (_tableView == self.searchDisplayController.searchResultsTableView) return nil;
    else return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)_tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (_tableView == self.searchDisplayController.searchResultsTableView) return 0;
    else return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    if (_tableView == self.searchDisplayController.searchResultsTableView) return 1;
    else return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableView == self.searchDisplayController.searchResultsTableView) return [filteredObjectsArray count];
    else return [[self getObjectsArrayInSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    
    ObjectCell *cell = (ObjectCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ObjectCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.tag = indexPath.row;
    ObjectIP *object = nil;
    
    if (_tableView == self.searchDisplayController.searchResultsTableView)
	{
        object = [filteredObjectsArray objectAtIndex:indexPath.row];
    }
	else
	{
        object = [[self getObjectsArrayInSection:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [cell setObject:object];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (_tableView == tableView) return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        selectedIndexPath = indexPath;
        
        if (_tableView == self.searchDisplayController.searchResultsTableView)
        {
            selectedArray = [self getObjectsAndSectionsArray];
            [self deleteObject];
        }
        else
        {
            selectedArray = [self getObjectsAndSectionsArray];
            [self deleteObject];
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView == self.searchDisplayController.searchResultsTableView)
	{
        [self goToObjectDetail:[filteredObjectsArray objectAtIndex:indexPath.row]];
    }
    else
    {        
        [self goToObjectDetail:[[self getObjectsArrayInSection:indexPath.section] objectAtIndex:indexPath.row]];        
    }
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    for (ObjectIP *object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:@selector(getCompareName)] mutableCopy]];
    }
    
    return sections;
}

- (NSMutableArray *)getObjectsInState:(ObjectState)state inArray:(NSArray *)array
{
    NSMutableArray *filteredArray = [NSMutableArray new];
    for (ObjectIP *object in array)
    {
        if ([object.state integerValue] == state) [filteredArray addObject:object];
    }
    return filteredArray;
}

- (NSMutableArray *)getObjectsAndSectionsInState:(ObjectState)state inArray:(NSArray *)array
{
    NSMutableArray *filteredArray = [NSMutableArray new];
    
    for (NSArray *section in array)
    {
        NSMutableArray *filteredSection = [NSMutableArray new];
        
        for (ObjectIP *object in section)
        {
            if ([object.state integerValue] == state) [filteredSection addObject:object];
        }
        
        [filteredArray addObject:filteredSection];
    }
    return filteredArray;
}

- (NSMutableArray *)getObjectsAndSectionsArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:objectsArray];
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 1:
            array = [self getObjectsAndSectionsInState:Property inArray:array];
            break;
        case 2:
            array = [self getObjectsAndSectionsInState:Given inArray:array];
            break;
    }
    
    return array;
}

- (NSMutableArray *)getObjectsArrayInSection:(NSInteger)section
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[objectsArray objectAtIndex:section]];
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 1:
            array = [self getObjectsInState:Property inArray:array];
            break;
        case 2:
            array = [self getObjectsInState:Given inArray:array];
            break;
    }
    
    if (array.count > 0) noObjectsView.hidden = YES;
    return array;
}

- (void)reloadTables
{
    noObjectsView.hidden = NO;
    [tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
