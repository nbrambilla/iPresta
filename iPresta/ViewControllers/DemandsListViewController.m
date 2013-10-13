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

@interface DemandsListViewController ()

@end

@implementation DemandsListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDemandsArray) name:@"setDemandsObserver" object:nil];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTableViewHeader
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Mis Pedidos", @"Pedidos de Amigos"]];
    segmentedControl.frame = CGRectMake(35, 200, 230, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(setDemandsType:) forControlEvents:UIControlEventValueChanged];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.titleView = segmentedControl;
    
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    self.tableView.tableHeaderView = navigationBar;
    
    navigationBar = nil;
    navigationItem = nil;
}

- (void)setDemandsType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) selectedArray = myDemandsArray;
    else if (sender.selectedSegmentIndex == 1) selectedArray = friendsDemandsArray;
    
    [self.tableView reloadData];
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
    return [selectedArray count];
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
    
    DemandIP *demand = [selectedArray objectAtIndex:indexPath.row];
    
    if (segmentedControl.selectedSegmentIndex == 1)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [demand.from getFullName], demand.object.name];
        cell.imageView.image = [UIImage imageWithData:demand.object.image];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
        cell.detailTextLabel.text = [dateFormat stringFromDate:demand.date];
    }
    else if (segmentedControl.selectedSegmentIndex == 0)
    {
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
