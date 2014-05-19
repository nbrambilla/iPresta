//
//  ObjectHistoricGiveViewController.m
//  iPresta
//
//  Created by Nacho on 03/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectHistoricGiveViewController.h"
#import "ObjectIP.h"
#import "GiveIP.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@interface ObjectHistoricGiveViewController ()

@end

@implementation ObjectHistoricGiveViewController

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
    self.title = IPString(@"Historico");
    noLoansLabel.text = IPString(@"No hay prestamos");
    
    givesArray = [[ObjectIP currentObject] getAllGives];
    noLoansView.hidden = (givesArray.count != 0);
    
    [tableView reloadData];
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
    return [givesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Give";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    GiveIP *give = [givesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = give.name;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:NSLocalizedString(@"Formato fecha", nil)];
    NSString *dateBegin = [dateFormat stringFromDate:give.dateBegin];
    NSString *dateEnd = [dateFormat stringFromDate:give.dateEnd];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"Desde", nil), dateBegin, NSLocalizedString(@"Hasta", nil), dateEnd];

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

@end
