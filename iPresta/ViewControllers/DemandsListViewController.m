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
#import "Language.h"

@interface DemandsListViewController ()

@end

@implementation DemandsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDemandsArray) name:@"setDemandsObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDemandsFriendsTable) name:@"ReloadFriendsDemandsTableObserver" object:nil];
    
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
        [objectsImageArray addObject:[NSNumber numberWithBool:NO]];
        [objectsArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self setDemandsType:segmentedControl];
}

- (void)reloadDemandsFriendsTable
{
    friendsDemandsArray = [DemandIP getFriends];
    [friendsDemadsTable reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTableViewHeader
{
    [segmentedControl setTitle:[Language get:@"Mis pedidos" alter:nil] forSegmentAtIndex:0];
    [segmentedControl setTitle:[Language get:@"Pedidos de amigos" alter:nil] forSegmentAtIndex:1];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(setDemandsType:) forControlEvents:UIControlEventValueChanged];
}

- (void)setDemandsType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        myDemadsTable.hidden = NO;
        friendsDemadsTable.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexPath.row;
    }
    
    
    if (tableView == friendsDemadsTable)
    {
        DemandIP *demand = [friendsDemandsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [demand.from getFullName], demand.object.name];
        cell.imageView.image = [UIImage imageWithData:demand.object.image];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
        cell.detailTextLabel.text = [dateFormat stringFromDate:demand.date];
    }
    else if (tableView == myDemadsTable)
    {
        DemandIP *demand = [myDemandsArray objectAtIndex:indexPath.row];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = cell.imageView.frame;
        [cell.imageView addSubview:indicator];
        [indicator startAnimating];
        
        if (![[objectsArray objectAtIndex:indexPath.row] isKindOfClass:[ObjectIP class]])
        {
            [ObjectIP getDBObjectWithObjectId:demand.iPrestaObjectId withBlock:^(NSError *error, ObjectIP *object)
            {
                [objectsArray replaceObjectAtIndex:indexPath.row withObject:object];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [demand.to getFullName], object.name];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
                cell.detailTextLabel.text = [dateFormat stringFromDate:demand.date];
                
                UIImage* image = [UIImage imageWithData:object.image];
                if (image)
                {
                    dispatch_async(dispatch_get_main_queue(),^
                       {
                           if (cell.tag == indexPath.row)
                           {
                               [indicator removeFromSuperview];
                               
                               [objectsImageArray replaceObjectAtIndex:indexPath.row withObject:image];
                               cell.imageView.image = image;
                               [cell setNeedsLayout];
                           }
                       });
                }
            }];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [demand.to getFullName], [[objectsArray objectAtIndex:indexPath.row] name]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
            cell.detailTextLabel.text = [dateFormat stringFromDate:demand.date];
            
            cell.imageView.image = [objectsImageArray objectAtIndex:indexPath.row];
    
        }
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

@end
