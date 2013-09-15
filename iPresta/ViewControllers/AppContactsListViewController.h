//
//  AppContactsListViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideTableViewController.h"
#import "UserIP.h"

@interface AppContactsListViewController : SlideTableViewController <UserIPDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *appContactsList;
    NSMutableArray *filteredAppContactsList;
    
    IBOutlet UISearchBar *searchBar;
}

@end
