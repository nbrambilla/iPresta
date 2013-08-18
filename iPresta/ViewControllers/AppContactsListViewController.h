//
//  AppContactsListViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 22/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideTableViewController.h"

@interface AppContactsListViewController : SlideTableViewController <UISearchDisplayDelegate>
{
    NSMutableArray *appContactsList;
    NSMutableArray *filteredAppContactsList;
    
    IBOutlet UISearchBar *searchBar;
}

@end
