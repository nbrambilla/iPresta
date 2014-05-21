//
//  AppContactsListViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "UserIP.h"

@interface AppContactsListViewController : SlideViewController <UserIPDelegate>
{
    NSMutableArray *appContactsList;
    NSMutableArray *filteredAppContactsList;
    
    IBOutlet UITableView *tableView;
    IBOutlet UISearchBar *searchBar;
}

@end
