//
//  DemandsListViewController.h
//  iPresta
//
//  Created by Nacho on 04/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "FriendsDemandsCell.h"

@class DemandIP;

@interface DemandsListViewController : SlideViewController <FriendsDemandsCellDelegate, UIAlertViewDelegate>
{
    NSArray *myDemandsArray;
    NSArray *friendsDemandsArray;
    
    NSMutableArray *objectsImageArray;
    NSMutableArray *objectsArray;
    
    UIAlertView *rejectAlert;
    UIAlertView *acceptAlert;
    
    IBOutlet UITableView *myDemadsTable;
    IBOutlet UITableView *friendsDemadsTable;
    IBOutlet UISegmentedControl *segmentedControl;
    
    DemandIP *demandToReject;
}

@end
