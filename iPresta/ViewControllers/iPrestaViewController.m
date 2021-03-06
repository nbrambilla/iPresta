//
//  iPrestaViewController.m
//  iPresta
//
//  Created by Nacho on 20/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaViewController.h"
#import "LoginViewController.h"
#import "CreateCountViewController.h"
#import "IPButton.h"

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

    [self setTexts];
}

- (void)setTexts
{
    [haveCountButton setTitle:IPString(@"Tengo una cuenta") forState:UIControlStateNormal];
    [createCountButton setTitle:IPString(@"Crear una cuenta") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToLogIn:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [navigationController pushViewController:loginViewController animated:YES];
    navigationController.navigationBar.opaque = YES;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)goToCreateCount:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    CreateCountViewController *createCountViewController = [[CreateCountViewController alloc] initWithNibName:@"CreateCountViewController" bundle:nil];
    [navigationController pushViewController:createCountViewController animated:NO];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
