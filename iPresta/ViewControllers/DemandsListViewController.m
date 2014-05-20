//
//  DemandsListViewController.m
//  iPresta
//
//  Created by Nacho on 04/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "DemandsListViewController.h"
#import "DemandIP.h"
#import "FriendIP.h"
#import "ObjectIP.h"
#import "GiveObjectViewController.h"
#import "MyDemandsCell.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "AsyncImageView.h"

@interface DemandsListViewController ()

@end

@implementation DemandsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = IPString(@"Pedidos");
    noDemandsLabel.text = IPString(@"No hay pedidos");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDemandsArray) name:@"setDemandsObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDemandsFriendsTable) name:@"ReloadFriendsDemandsTableObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyDemandsTable) name:@"ReloadMyDemandsTableObserver" object:nil];
    
    [self setTableViewHeader];
    [self setDemandsArray];
}

- (void)setDemandsArray
{
    myDemandsArray = [DemandIP getMines];
    friendsDemandsArray = [DemandIP getFriends];
    objectsImageArray = [[NSMutableArray alloc] initWithCapacity:[myDemandsArray count]];
    objectsArray = [[NSMutableArray alloc] initWithCapacity:[myDemandsArray count]];
    
    for (int i = 0; i < [myDemandsArray count]; i++)
    {
        [objectsImageArray addObject:@NO];
        [objectsArray addObject:@NO];
    }
    
    [self setDemandsType:segmentedControl];
}

- (void)reloadDemandsFriendsTable
{
    friendsDemandsArray = [DemandIP getFriends];
    [friendsDemadsTable reloadData];
}

- (void)reloadMyDemandsTable
{
    myDemandsArray = [DemandIP getMines];
    [myDemadsTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [friendsDemadsTable reloadData];
}

- (void)setTableViewHeader
{
    [segmentedControl setTitle:IPString(@"Mis pedidos") forSegmentAtIndex:0];
    [segmentedControl setTitle:IPString(@"Pedidos de amigos") forSegmentAtIndex:1];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(setDemandsType:) forControlEvents:UIControlEventValueChanged];
}

- (void)setDemandsType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        noDemandsView.hidden = (myDemandsArray.count != 0);
        
        myDemadsTable.hidden = NO;
        friendsDemadsTable.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        noDemandsView.hidden = (friendsDemandsArray.count != 0);
        
        myDemadsTable.hidden = YES;
        friendsDemadsTable.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == myDemadsTable) return myDemandsArray.count;
    return friendsDemandsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == friendsDemadsTable)
    {
        static NSString *CellIdentifier = @"Cell";
        FriendsDemandsCell *cell = (FriendsDemandsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendsDemandsCell" owner:self options:nil] objectAtIndex:0];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
        }
        
        [cell setDemand:[friendsDemandsArray objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else if (tableView == myDemadsTable)
    {
        static NSString *CellIdentifier = @"Cell";
        MyDemandsCell *cell = (MyDemandsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyDemandsCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
        }
        
        DemandIP *demand = [myDemandsArray objectAtIndex:indexPath.row];
        
        if (![[objectsArray objectAtIndex:indexPath.row] isKindOfClass:[ObjectIP class]])
        {
            [ObjectIP getDBObjectWithObjectId:demand.iPrestaObjectId withBlock:^(NSError *error, ObjectIP *object)
            {
                [objectsArray replaceObjectAtIndex:indexPath.row withObject:object];
                [cell setDemand:demand withObjectName:object.name];
                
                if (demand.object.imageURL)
                {
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.objectImageView];
                    cell.objectImageView.imageURL = [NSURL URLWithString:demand.object.imageURL];
                }
                else cell.objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[demand.object.type integerValue]]];

            }];
        }
        else
        {
            ObjectIP *object = [objectsArray objectAtIndex:indexPath.row];
            [cell setDemand:demand withObjectName:object.name];
            if (demand.object.imageURL)
            {
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.objectImageView];
                cell.objectImageView.imageURL = [NSURL URLWithString:demand.object.imageURL];
            }
            else cell.objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[demand.object.type integerValue]]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)acceptDemand:(DemandIP *)demand
{
    if (demand.object.state == [NSNumber numberWithInteger:Given]) {
        NSString *message = [NSString stringWithFormat:IPString(@"Objeto prestado"), demand.object.name];
        rejectAlert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [rejectAlert show];
    }
    else if (demand.object.state == [NSNumber numberWithInteger:Property])
    {
        [ObjectIP setCurrentObject:demand.object];
        GiveObjectViewController *viewController = [[GiveObjectViewController alloc] initWithNibName:@"GiveObjectViewController" bundle:nil];
        viewController.demand = demand;
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController = nil;
    }
}

- (void)rejectDemand:(DemandIP *)demand
{
    demandToReject = demand;
    NSString *message = [NSString stringWithFormat:IPString(@"Pregunta rechazar prestamo"), demand.object.name, [demand.from getFullName]];
    rejectAlert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:self cancelButtonTitle:IPString(@"Cancelar") otherButtonTitles:IPString(@"rechazar"), nil];
    [rejectAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == rejectAlert)
    {
        if (buttonIndex == 1)
        {
            [ProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [demandToReject rejectWithBlock:^(NSError *error)
            {
                [ProgressHUD hideHUDForView:self.view animated:YES];
                
                if (!error){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
                    [self reloadDemandsFriendsTable];
                }
                else [error manageError];
            }];
            
            demandToReject = nil;
        }
    }
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
