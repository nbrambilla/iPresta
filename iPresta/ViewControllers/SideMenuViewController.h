//
//  SideMenuViewController.h
//  UseTaxi
//
//  Created by Nacho on 06/08/13.
//  Copyright (c) 2013 Nostro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenuContainerViewController.h"

@interface SideMenuViewController : UITableViewController
{
    int selectedSection;
    int selectedRow;
}

- (void)reloadData;

@end
