//
//  DemandsListViewController.h
//  iPresta
//
//  Created by Nacho on 04/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideTableViewController.h"

@interface DemandsListViewController : SlideTableViewController
{
    NSArray *demandsArray;
    UISegmentedControl *segmentedControl;
}

@end
