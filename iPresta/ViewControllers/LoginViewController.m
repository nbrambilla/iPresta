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
#import "iPrestaNavigationController.h"
#import "RequestPasswordResetViewController.h"
#import "ObjectsListViewController.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "User.h"

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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"iPresta";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Volver", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToBegin)];
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
        if ([emailTextField.text isValidEmail]) // Si el email tiene el formato valido
        {
            [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
            
            [User logInWithUsernameInBackground:emailTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error)
            {
                [ProgressHUD hideHUDForView:self.view.window animated:YES];
                
                if (error) [error manageErrorTo:self];      // Si hay error en el login
                else [self logInSuccess];                   // Si el login se realiza correctamente
            }];
            
        }
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
    UINavigationController *navigationController;
    
    // Si es un usuario ya autenticado, accede a la aplicacion
    
    if ([User currentUserHasEmailVerified])
    {
        UINavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        UITableViewController *tableViewcontroller = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
        [navigationController pushViewController:tableViewcontroller animated:NO];
        
        [self presentModalViewController:navigationController animated:YES];
        
        tableViewcontroller = nil;
    }
    // Si el usuario no esta autenticado, debe hacerlo confirmando su email. Accede a la pantalla de autenticacion
    else
    {
        UIViewController *viewController;

        viewController =  [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
        [navigationController pushViewController:viewController animated:NO];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController = nil;
    }
    
    navigationController = nil;
}

@end
