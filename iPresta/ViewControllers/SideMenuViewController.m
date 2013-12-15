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
#import "AppContactsListViewController.h"
#import "ConfigurationViewController.h"
#import "SearchObjectsViewController.h"
#import "LoansListViewController.h"
#import "DemandsListViewController.h"
#import "IMOAutocompletionViewController.h"
#import "FriendsCell.h"
#import "GivesCell.h"
#import "DemandsCell.h"
#import "MenuCell.h"


@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewDemands) name:@"RefreshNewDemandsObserver" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewGives) name:@"RefreshNewGivesObserver" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewFriends) name:@"RefreshNewFriendsObserver" object:nil];
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
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"iPresta";
}
- (void)refreshNewFriends
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.row == 2) {
        FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = NSLocalizedString(@"Contactos", nil);
        cell.imageView.image = [UIImage imageNamed:@"contacts_icon.png"];
        [cell setNews:[FriendIP newFriends]];
        
        return cell;
    }
    else if (indexPath.row == 3)
    {
        DemandsCell *cell = (DemandsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DemandsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.title.text = NSLocalizedString(@"Pedidos pendientes", nil);
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
        
        cell.title.text = NSLocalizedString(@"Prestamos expirados", nil);
        cell.imageView.image = [UIImage imageNamed:@"loan_icon.png"];
        
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
                cell.textLabel.text = NSLocalizedString(@"Objetos", nil);
                cell.imageView.image = [UIImage imageNamed:@"objects_icon.png"];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Buscar", nil);
                cell.imageView.image = [UIImage imageNamed:@"search_icon.png"];
                break;
            case 5:
                cell.textLabel.text = NSLocalizedString(@"Configuracion", nil);
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
                viewController = [[AppContactsListViewController alloc] initWithNibName:@"AppContactsListViewController" bundle:nil];
                break;
            case 3:
                viewController = [[DemandsListViewController alloc] initWithNibName:@"DemandsListViewController" bundle:nil];
                break;
            case 4:
                viewController = [[LoansListViewController alloc] initWithNibName:@"LoansListViewController" bundle:nil];
                break;
            case 5:
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

@end
