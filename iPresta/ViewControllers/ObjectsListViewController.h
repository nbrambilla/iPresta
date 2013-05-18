//
//  ObjectsListViewController.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectsListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    @private
    NSMutableArray *objectsArray;
}

@property(strong, nonatomic) NSMutableArray *objectsArray;

@end
