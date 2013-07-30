//
//  ObjectHistoricGiveViewController.m
//  iPresta
//
//  Created by Nacho on 03/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectHistoricGiveViewController.h"
#import "iPrestaObject.h"
#import "Give.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@interface ObjectHistoricGiveViewController ()

@end

@implementation ObjectHistoricGiveViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTableView
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *getObjectsGivesQuery = [Give query];
    [getObjectsGivesQuery whereKey:@"object" equalTo:[iPrestaObject currentObject]];
    getObjectsGivesQuery.limit = 1000;
    
    [getObjectsGivesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];          // Si hay error al obtener los objetos
         else                                            // Si se obtienen los objetos, se listan
         {
             givesArray = [objects mutableCopy];
          
             givesArray = [givesArray sortedArrayUsingComparator:^NSComparisonResult(Give *a, Give *b) {
                 NSDate *first = a.dateBegin;
                 NSDate *second = b.dateBegin;
                 return [second compare:first];
             }];
             
             [self.tableView reloadData];
             
         }
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [givesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Give";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Give *give = [givesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = give.name;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
    NSString *dateBegin = [dateFormat stringFromDate:give.dateBegin];
    NSString *dateEnd = [dateFormat stringFromDate:give.dateEnd];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Desde %@ hasta %@", dateBegin, dateEnd];
    
    give = nil;
    dateFormat = nil;
    dateBegin = nil;
    dateEnd = nil;
    
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
