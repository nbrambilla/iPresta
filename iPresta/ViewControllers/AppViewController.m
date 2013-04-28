//
//  AppViewController.m
//  iPresta
//
//  Created by Nacho on 28/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AppViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "iPrestaNavigationController.h"

@interface AppViewController ()

@end

@implementation AppViewController

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
    
    NSLog(@"%@", self.parentViewController);
    
    textLabel.text = [NSString stringWithFormat:@"Dentro de la appa con el usuario %@", [[User currentUser] email]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    textLabel = nil;
    [super viewDidUnload];
}

- (IBAction)logOut:(id)sender
{
    [User logOut];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
