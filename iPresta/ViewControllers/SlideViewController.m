//
//  SlideViewController.m
//  UseTaxi
//
//  Created by Nacho on 07/08/13.
//  Copyright (c) 2013 Nostro Studio. All rights reserved.
//

#import "SlideViewController.h"
#import "UserIP.h"


@interface SlideViewController ()

@end

@implementation SlideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![UserIP objectsUserIsSet]) self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
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
    if (![UserIP objectsUserIsSet]) self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
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
