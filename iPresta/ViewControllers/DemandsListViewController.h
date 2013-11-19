//
//  DemandsListViewController.h
//  iPresta
//
//  Created by Nacho on 04/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"

@interface DemandsListViewController : SlideViewController
{
    NSArray *myDemandsArray;
    NSArray *friendsDemandsArray;
    
    NSMutableArray *objectsImageArray;
    NSMutableArray *objectsArray;
    
    IBOutlet UITableView *myDemadsTable;
    IBOutlet UITableView *friendsDemadsTable;
    IBOutlet UISegmentedControl *segmentedControl;
}

@end
