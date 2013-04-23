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
    
    [User setDelegate:self];
    
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

- (void)viewDidUnload {
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
}

- (IBAction)login:(id)sender
{
    [User logOut];
    
    if ([self fieldsAreSet])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [User logInUserWithUsername:emailTextField.text andPassword:passwordTextField.text];
    }
}

#pragma mark - Login Functions

- (void)backFromLogin
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([User currentUser] != nil)
    {
        [self loginOk];
    }
    else
    {
        [self errorToLogin];
    }
}

- (void)errorToLogin
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Email y/o password incorrecto" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
        [alert show];
}

- (void)loginOk
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Login OK!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - Check Fields Functions

- (BOOL)fieldsAreSet
{
    BOOL bReturn = ([emailTextField.text length] == 0 || [passwordTextField.text length] == 0);
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Deben completarse el email y la contraseña" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    return bReturn;
}

@end
