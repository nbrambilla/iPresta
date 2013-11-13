//
//  LoginViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "LoginViewController.h"
#import "CreateCountViewController.h"
#import "AuthenticateEmailViewController.h"
#import "RequestPasswordResetViewController.h"
#import "ObjectsMenuViewController.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
#import "SideMenuViewController.h"
#import "ProgressHUD.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - Lifecycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iPresta";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Volver", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToBegin)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
    [ObjectIP setLoginDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
    [ObjectIP setLoginDelegate:nil];
}

- (void)backToBegin
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)login:(id)sender
{
    if ([NSString areSetUsername:emailTextField.text andPassword:passwordTextField.text]) // Si los campos estan completados
    {
        if ([[emailTextField.text lowercaseString] isValidEmail]) // Si el email tiene el formato valido
        {
            [ProgressHUD showHUDAddedTo:self.view animated:YES];
            [UserIP logInWithUsername:emailTextField.text password:passwordTextField.text];
        }
    }
}

- (IBAction)loginButtonTouchHandler:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [UserIP loginWithFacebook];
}

- (void)logInResult:(NSError *)error
{
    if (error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        [error manageErrorTo:self];      // Si hay error en el login
    }
    else [self logInSuccess];
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
    UINavigationController *navigationController;
    // Si es un usuario ya autenticado, se guardan los objetos del usuario
    
    if (![UserIP isNew]) [UserIP setDevice];
    // Si el usuario no esta autenticado, debe hacerlo confirmando su email. Accede a la pantalla de autenticacion
    else
    {
        UIViewController *viewController =  [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
        [navigationController pushViewController:viewController animated:NO];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController = nil;
    }
    
    navigationController = nil;
}

- (void)setDeciveResult:(NSError *)error
{
    if (error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        [error manageErrorTo:self];
    }
    else [ObjectIP saveAllObjectsFromDB];
}

- (void)saveAllObjectsFromDBresult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];      // Si hay error guardar los objetos
    else [self goToApp];
}

- (void)goToApp
{
    UIViewController *viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
    [self presentViewController:container animated:YES completion:nil];
    
    viewController = nil;
    navigationController = nil;
    leftMenuViewController = nil;
    container = nil;
}

@end
