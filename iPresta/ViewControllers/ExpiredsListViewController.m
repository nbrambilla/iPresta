//
//  LoansListViewController.m
//  iPresta
//
//  Created by Nacho on 08/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ExpiredsListViewController.h"
#import "GiveIP.h"
#import "MyGiveCell.h"
#import "FriendGiveCell.h"
#import "ObjectIP.h"
#import "AsyncImageView.h"

@interface ExpiredsListViewController ()

@end

@implementation ExpiredsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [friendsGivesTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setGivesArray) name:@"setExtendsObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriendsGivesTable) name:@"ReloadFriendsExtendsTableObserver" object:nil];
    [self setTableViewHeader];
    [self setGivesArray];
}

- (void)reloadFriendsGivesTable
{
    friendsGivesArray = [GiveIP getFriendsExpired];
    [friendsGivesTable reloadData];
}

- (void)setTableViewHeader
{
    [segmentedControl setTitle:NSLocalizedString(@"Expirados mios", nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedString(@"Expirados de amigos", nil) forSegmentAtIndex:1];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(setGivesType:) forControlEvents:UIControlEventValueChanged];
}

- (void)setGivesArray
{
    myGivesArray = [GiveIP getMinesExpired];
    friendsGivesArray = [GiveIP getFriendsExpired];
    objectsImageArray = [[NSMutableArray alloc] initWithCapacity:[friendsGivesArray count]];
    objectsArray = [[NSMutableArray alloc] initWithCapacity:[friendsGivesArray count]];
    
    for (int i = 0; i < [friendsGivesArray count]; i++)
    {
        [objectsImageArray addObject:@NO];
        [objectsArray addObject:@NO];
    }
    
    [self setGivesType:segmentedControl];
    [friendsGivesTable reloadData];
}

- (void)setGivesType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        myGivesTable.hidden = NO;
        friendsGivesTable.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        myGivesTable.hidden = YES;
        friendsGivesTable.hidden = NO;
    }
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
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
    if (tableView == myGivesTable) return myGivesArray.count;
    return friendsGivesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == friendsGivesTable)
    {
        static NSString *CellIdentifier = @"Cell";
        FriendGiveCell *cell = (FriendGiveCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendGiveCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
        }

        GiveIP *give = [friendsGivesArray objectAtIndex:indexPath.row];

        if (![[objectsArray objectAtIndex:indexPath.row] isKindOfClass:[ObjectIP class]])
        {
            [ObjectIP getDBObjectWithObjectId:give.iPrestaObjectId withBlock:^(NSError *error, ObjectIP *object)
             {
                 [objectsArray replaceObjectAtIndex:indexPath.row withObject:object];
                 [cell setGive:give withObjectName:object.name];

                 if (give.object.imageURL)
                 {
                     [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.objectImageView];
                     cell.objectImageView.imageURL = [NSURL URLWithString:give.object.imageURL];
                 }
                 else cell.objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[give.object.type integerValue]]];
             }];
        }
        else
        {
            ObjectIP *object = [objectsArray objectAtIndex:indexPath.row];
            [cell setGive:give withObjectName:object.name];
            if (give.object.imageURL)
            {
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.objectImageView];
                cell.objectImageView.imageURL = [NSURL URLWithString:give.object.imageURL];
            }
            else cell.objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[give.object.type integerValue]]];
        }
        
        return cell;
    }
    else if (tableView == myGivesTable)
    {
        static NSString *CellIdentifier = @"Cell";
        MyGiveCell *cell = (MyGiveCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyGiveCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
        }
        
        [cell setGive:[myGivesArray objectAtIndex:indexPath.row]];
        
        return cell;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
