//
//  SideMenuViewController.m
//  UseTaxi
//
//  Created by Nacho on 06/08/13.
//  Copyright (c) 2013 Nostro Studio. All rights reserved.
//

#import "DemandIP.h"
#import "GiveIP.h"
#import "FriendIP.h"
#import "SideMenuViewController.h"
#import "ObjectsMenuViewController.h"
#import "ContactsListViewController.h"
#import "ConfigurationViewController.h"
#import "SearchObjectsViewController.h"
#import "LoansListViewController.h"
#import "ExpiredsListViewController.h"
#import "DemandsListViewController.h"
#import "IMOAutocompletionViewController.h"
#import "FriendsCell.h"
#import "GivesCell.h"
#import "DemandsCell.h"
#import "MenuCell.h"

#define HEADER_HEIGHT 64.0f

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewDemands) name:@"RefreshNewDemandsObserver" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewGives) name:@"RefreshNewGivesObserver" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewExtends) name:@"RefreshNewExtendsObserver" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenuCells) name:@"RefreshMenuCellsObserver" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewFriends) name:@"RefreshNewFriendsObserver" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedSection = 0;
    selectedRow = 0;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return APP_NAME;
}

//- (void)refreshNewFriends
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
//}

- (void)refreshNewDemands
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)refreshNewGives
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)refreshNewExtends
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:5 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)refreshMenuCells
{
    [self refreshNewDemands];
    [self refreshNewGives];
    [self refreshNewExtends];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.row == 2) {
        FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = IPString(@"Contactos");
        cell.imageView.image = [UIImage imageNamed:@"contacts_icon.png"];
//        [cell setNews:[FriendIP newFriends]];
        
        return cell;
    }
    else if (indexPath.row == 3)
    {
        DemandsCell *cell = (DemandsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DemandsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.title.text = IPString(@"Pedidos");
        cell.imageView.image = [UIImage imageNamed:@"orders_icon.png"];
        
        [cell setMines:[[DemandIP getMines] count]];
        [cell setFriends:[[DemandIP getFriends] count]];
        
        return cell;
    }
    else if (indexPath.row == 4)
    {
        GivesCell *cell = (GivesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GivesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.title.text = IPString(@"Prestamos");
        cell.imageView.image = [UIImage imageNamed:@"loan_icon.png"];
        
        [cell setMines:[[GiveIP getMinesInTime] count]];
        [cell setFriends:[[GiveIP getFriendsInTime] count]];
        
        return cell;
    }
    else if (indexPath.row == 5)
    {
        GivesCell *cell = (GivesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GivesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.title.text = IPString(@"Expirados");
        cell.imageView.image = [UIImage imageNamed:@"expired_icon.png"];
        
        [cell setMines:[[GiveIP getMinesExpired] count]];
        [cell setFriends:[[GiveIP getFriendsExpired] count]];
        
        return cell;
    }
    else
    {
        MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = IPString(@"Objetos");
                cell.imageView.image = [UIImage imageNamed:@"objects_icon.png"];
                break;
            case 1:
                cell.textLabel.text = IPString(@"Buscar");
                cell.imageView.image = [UIImage imageNamed:@"search_icon.png"];
                break;
            case 6:
                cell.textLabel.text = IPString(@"Configuracion");
                cell.imageView.image = [UIImage imageNamed:@"config_icon.png"];
                break;
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)reloadData
{
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedSection != indexPath.section || selectedRow != indexPath.row)
    {
        id viewController;
        
        switch (indexPath.row)
        {
            case 0:
                viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
                break;
            case 1:
                viewController = [[SearchObjectsViewController alloc] initWithCancelButton:NO andPagination:YES nibName:@"IMOAutocompletionViewController"];
                break;
            case 2:
                viewController = [[ContactsListViewController alloc] initWithNibName:@"ContactsListViewController" bundle:nil];
                break;
            case 3:
                viewController = [[DemandsListViewController alloc] initWithNibName:@"DemandsListViewController" bundle:nil];
                break;
            case 4:
                viewController = [[LoansListViewController alloc] initWithNibName:@"LoansListViewController" bundle:nil];
                break;
            case 5:
                viewController = [[ExpiredsListViewController alloc] initWithNibName:@"ExpiredsListViewController" bundle:nil];
                break;
            case 6:
                viewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:nil];
                break;
        }
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        navigationController.viewControllers = controllers;
        
        selectedSection = indexPath.section;
        selectedRow = indexPath.row;
    }
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [UIView new];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor blackColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, headerView.frame.size.width, headerView.frame.size.height - 20.0f)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"Menu";
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:titleLabel];
    
    return headerView;
}


@end
