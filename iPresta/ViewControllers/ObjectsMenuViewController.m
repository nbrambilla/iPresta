//
//  ObjectsMenuViewController.m
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectsMenuViewController.h"
#import "ObjectsListViewController.h"
#import "ConfigurationViewController.h"
#import "iPrestaObject.h"

@interface ObjectsMenuViewController ()

@end

@implementation ObjectsMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Menú";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *configurationObjectlButton = [[UIBarButtonItem alloc] initWithTitle:@"Config" style:UIBarButtonItemStyleBordered target:self action:@selector(goToConfiguration)];
    self.navigationItem.rightBarButtonItem = configurationObjectlButton;
    
    booksListButton.tag = BookType;
    audioListButton.tag = AudioType;
    videoListButton.tag = VideoType;
    othersListButton.tag = OtherType;

    configurationObjectlButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToObjectsList:(id)sender
{
    ObjectsListViewController *viewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
    UIButton *pressedButton = (UIButton *)sender;
    [iPrestaObject setTypeSelected:pressedButton.tag];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
    pressedButton = nil;
}

- (void)goToConfiguration
{
    ConfigurationViewController *viewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    viewController = nil;
    navigationController = nil;
}

- (void)viewDidUnload
{
    booksListButton = nil;
    audioListButton = nil;
    videoListButton = nil;
    othersListButton = nil;
    [super viewDidUnload];
}
@end
