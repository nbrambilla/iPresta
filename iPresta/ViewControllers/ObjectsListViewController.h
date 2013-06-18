//
//  ObjectsListViewController.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectsListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UINavigationControllerDelegate>
{
    @private
    NSMutableArray *filteredObjectsArray;
    IBOutlet UISearchBar *searchBar;
    UISegmentedControl *segmentedControl;
}

@end
