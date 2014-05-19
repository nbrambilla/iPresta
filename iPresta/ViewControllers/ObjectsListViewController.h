//
//  ObjectsListViewController.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"

@interface ObjectsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UINavigationControllerDelegate, ObjectIPDelegate>
{
    @private
    IBOutlet UITableView *tableView;
    NSMutableArray *filteredObjectsArray;
    IBOutlet UISearchBar *searchBar;
    UISegmentedControl *segmentedControl;
    NSArray *objectsArray;
    NSIndexPath *selectedIndexPath;
    NSArray *selectedArray;
    
    IBOutlet UIView *noObjectsView;
    IBOutlet UILabel *noObjectsLabel;
}

@end
