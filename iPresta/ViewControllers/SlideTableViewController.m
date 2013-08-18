//
//  SlideTableViewController.m
//  iPresta
//
//  Created by Nacho on 15/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SlideTableViewController.h"

@interface SlideTableViewController ()

@end

@implementation SlideTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (UIBarButtonItem *)leftMenuBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(leftSideMenuButtonPressed:)];
}

- (void)setupMenuBarButtonItems
{
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
