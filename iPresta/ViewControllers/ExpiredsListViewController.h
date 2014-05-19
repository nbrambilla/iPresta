//
//  LoansListViewController.h
//  iPresta
//
//  Created by Nacho on 08/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SlideViewController.h"

@interface ExpiredsListViewController : SlideViewController
{
    NSArray *myGivesArray;
    NSArray *friendsGivesArray;
    
    NSMutableArray *objectsImageArray;
    NSMutableArray *objectsArray;
    
    IBOutlet UITableView *myGivesTable;
    IBOutlet UITableView *friendsGivesTable;
    IBOutlet UISegmentedControl *segmentedControl;
    
    IBOutlet UIView *noExpiredsView;
    IBOutlet UILabel *noExpiredsLabel;
}

@end
