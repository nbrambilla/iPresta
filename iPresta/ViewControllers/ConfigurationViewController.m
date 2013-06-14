//
//  ConfigurationViewController.m
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "iPrestaViewController.h"
#import "User.h"

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Configuración";
    }
    return self;
}

- (IBAction)logOut:(id)sender
{
    [User logOut];
    if ([self.presentingViewController isKindOfClass:[iPrestaViewController class]])
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Volver" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
    backButton = nil;
}

- (void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
