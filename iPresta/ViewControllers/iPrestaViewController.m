//
//  iPrestaViewController.m
//  iPresta
//
//  Created by Nacho on 20/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaViewController.h"
#import "iPrestaNavigationController.h"
#import "LoginViewController.h"
#import "CreateCountViewController.h"

@interface iPrestaViewController ()

@end

@implementation iPrestaViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToLogIn:(id)sender
{
    iPrestaNavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [navigationController pushViewController:loginViewController animated:NO];
    
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)goToCreateCount:(id)sender
{
    iPrestaNavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
    CreateCountViewController *createCountViewController = [[CreateCountViewController alloc] initWithNibName:@"CreateCountViewController" bundle:nil];
    [navigationController pushViewController:createCountViewController animated:NO];
    
    [self presentModalViewController:navigationController animated:YES];
}

@end
