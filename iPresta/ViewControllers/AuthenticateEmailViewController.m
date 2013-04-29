//
//  AuthenticateEmailViewController.m
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AuthenticateEmailViewController.h"
#import "MBProgressHUD.h"
#import "iPrestaNSString.h"
#import "ChangeEmailViewController.h"
#import "AppViewController.h"
#import "iPrestaNavigationController.h"

@interface AuthenticateEmailViewController ()

@end

@implementation AuthenticateEmailViewController

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
    
    self.title = @"Autenticar email";
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Cambiar email" style:UIBarButtonItemStylePlain target:self action:@selector(goToChangeEmail)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)resendAuthenticateEmailMassage:(id)sender
{
    [User setDelegate:self];
//    [User requestPasswordResetForEmail:[[User currentUser] email]];
}

- (IBAction)goToApp:(id)sender
{
    [User setDelegate:self];
    [[User currentUser] checkEmailAuthentication];
}

- (void)checkEmailAuthenticationSuccess
{
    if ([[User currentUser] emailVerified])
    {
        UINavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        AppViewController *appViewController = [[AppViewController alloc] initWithNibName:@"AppViewController" bundle:nil];
        [navigationController pushViewController:appViewController animated:NO];
        
        [self presentModalViewController:navigationController animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"El email no esta Autenticado" message:@"Debe autenticar su email para poder acceder a la app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)goToChangeEmail
{
    ChangeEmailViewController *changeEmailViewController = [[ChangeEmailViewController alloc] initWithNibName:@"ChangeEmailViewController" bundle:nil];
    
    [self.navigationController pushViewController:changeEmailViewController animated:YES];
}

- (void)viewDidUnload
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
