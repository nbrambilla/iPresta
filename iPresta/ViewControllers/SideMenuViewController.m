//
//  SideMenuViewController.m
//  UseTaxi
//
//  Created by Nacho on 06/08/13.
//  Copyright (c) 2013 Nostro Studio. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "ObjectsMenuViewController.h"
#import "AppContactsListViewController.h"
#import "ConfigurationViewController.h"
#import "SearchObjectsViewController.h"
#import "DemandsListViewController.h"
#import "IMOAutocompletionViewController.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

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
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"iPresta";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Objetos";
            cell.imageView.image = [UIImage imageNamed:@"objects_icon.png"];
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"search_icon.png"];
            cell.textLabel.text = @"Buscar";
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"contacts_icon.png"];
            cell.textLabel.text = @"Contactos";
            break;
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"orders_icon.png"];
            cell.textLabel.text = @"Pedidos";
            break;
        case 4:
            cell.imageView.image = [UIImage imageNamed:@"config_icon.png"];
            cell.textLabel.text = @"Configuración";
            break;
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
