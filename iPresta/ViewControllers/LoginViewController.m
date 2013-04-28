//
//  LoginViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "LoginViewController.h"
#import "CreateCountViewController.h"
#import "MBProgressHUD.h"
#import "AuthenticateEmailViewController.h"
#import "iPrestaNavigationController.h"
#import "RequestPasswordResetViewController.h"
#import "AppViewController.h"
#import "iPrestaNSString.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - ViewController Functions

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
    
    self.title = @"iPresta";
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)hideKeyboard:(id)sender
{
    if ([emailTextField isFirstResponder]) [emailTextField resignFirstResponder];
    else if ([passwordTextField isFirstResponder]) [passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    emailTextField = nil;
    passwordTextField = nil;
    entrarButton = nil;
    [super viewDidUnload];
}

#pragma mark - Button Functions

- (IBAction)goToCreateCount:(id)sender
{
    CreateCountViewController *createCountViewController = [[CreateCountViewController alloc] initWithNibName:@"CreateCountViewController" bundle:nil];
    [self.navigationController pushViewController:createCountViewController animated:YES];
    
    createCountViewController = nil;
}

- (IBAction)login:(id)sender
{
    [User setDelegate:self];
    
    // Si los campos estan completados, se realiza el login
    if ([NSString areSetUsername:emailTextField.text andPassword:passwordTextField.text])
    {
        [User logInUserWithUsername:emailTextField.text andPassword:passwordTextField.text];
    }
}

- (IBAction)goToRequestPasswordReset:(id)sender
{
    RequestPasswordResetViewController *requestPasswordResetViewController = [[RequestPasswordResetViewController alloc] initWithNibName:@"RequestPasswordResetViewController" bundle:nil];
    [self.navigationController pushViewController:requestPasswordResetViewController animated:YES];
    
    requestPasswordResetViewController = nil;
}

#pragma mark - Login Functions

- (void)logInSuccess
{
    UIViewController *viewController;
    UINavigationController *navigationController;
    
    // Si es un usuario ya autenticado, accede a la aplicacion
    
    if ([[User currentUser] emailVerified])
    {
        UINavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        AppViewController *appViewController = [[AppViewController alloc] initWithNibName:@"AppViewController" bundle:nil];
        [navigationController pushViewController:appViewController animated:NO];
        
        [self presentModalViewController:navigationController animated:YES];
    }
    // Si el usuario no esta autenticado, debe hacerlo confirmando su email. Accede a la pantalla de autenticacion
    else
    {
        navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        viewController =  [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
        [navigationController pushViewController:viewController animated:NO];
        
        [self presentModalViewController:navigationController animated:YES];
    }
    
    viewController = nil;
    navigationController = nil;
}

@end
