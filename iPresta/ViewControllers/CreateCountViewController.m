//
//  CreateCountViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CreateCountViewController.h"
#import "AuthenticateEmailViewController.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "UserIP.h"

@interface CreateCountViewController ()

@end

@implementation CreateCountViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Volver", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToBegin)];
    [createCountButton setTitle:NSLocalizedString(@"Crear cuenta", nil) forState:UIControlStateNormal];
    emailTextField.placeholder = NSLocalizedString(@"Email", nil);
    passwordTextField.placeholder = NSLocalizedString(@"Contraseña", nil);
    repeatPasswordTextField.placeholder = NSLocalizedString(@"Repetir contraseña", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
}

- (void)backToBegin
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)hideKeyboard:(id)sender
{
    if ([emailTextField isFirstResponder]) [emailTextField resignFirstResponder];
    else if ([passwordTextField isFirstResponder]) [passwordTextField resignFirstResponder];
    else if ([repeatPasswordTextField isFirstResponder]) [repeatPasswordTextField resignFirstResponder];
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
    repeatPasswordTextField = nil;
    
    [super viewDidUnload];
}

#pragma mark - SignUp Functions

- (IBAction)createCount:(id)sender
{
    if ([emailTextField.text isValidEmail])
    {
        if ([passwordTextField.text isValidPassword])
        {
            if ([passwordTextField.text matchWith:repeatPasswordTextField.text])
            {
                [ProgressHUD showHUDAddedTo:self.view animated:YES];
                
                [UserIP signUpWithEmail:emailTextField.text andPassword:passwordTextField.text];
            }
        }
    }
}

- (void)signUpResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];  // Si hay error en el registro
    else [self signInSuccess];              // Si el registro se realiza correctamente
}

- (void)signInSuccess
{
    AuthenticateEmailViewController *authenticateEmailViewController = [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
    [self.navigationController pushViewController:authenticateEmailViewController animated:YES];
    
    authenticateEmailViewController = nil;
}

@end
