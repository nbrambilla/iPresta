//
//  CreateCountViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CreateCountViewController.h"
#import "AuthenticateEmailViewController.h"
#import "SideMenuViewController.h"
#import "ObjectsMenuViewController.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "UserIP.h"
#import "IPButton.h"
#import "IPTextField.h"

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
    
    // Set Form
    
    form = [EZForm new];
    form.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    form.delegate = self;
    
    EZFormTextField *emailField = [[EZFormTextField alloc] initWithKey:@"name"];
    emailField.validationMinCharacters = 1;
    emailField.inputMaxCharacters = 50;
    
    EZFormTextField *passwordField = [[EZFormTextField alloc] initWithKey:@"author"];
    passwordField.validationMinCharacters = 0;
    passwordField.inputMaxCharacters = 12;
    
    EZFormTextField *repeatPasswordField = [[EZFormTextField alloc] initWithKey:@"editorial"];
    repeatPasswordField.validationMinCharacters = 0;
    repeatPasswordField.inputMaxCharacters = 12;
    
    [form addFormField:emailField];
    [form addFormField:passwordField];
    [form addFormField:repeatPasswordField];
    
    [emailField useTextField:emailTextField];
    [passwordField useTextField:passwordTextField];
    [repeatPasswordField useTextField:repeatPasswordTextField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkValidForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UserIP setDelegate:self];
    [ObjectIP setLoginDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    else if ([repeatPasswordTextField isFirstResponder]) [repeatPasswordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkValidForm
{
    createCountButton.enabled = (form.isFormValid) ? YES : NO;
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
//        if ([passwordTextField.text isValidPassword])
//        {
            if ([passwordTextField.text matchWith:repeatPasswordTextField.text])
            {
                [ProgressHUD showHUDAddedTo:self.view animated:YES];
                
                [UserIP signUpWithEmail:emailTextField.text andPassword:passwordTextField.text];
            }
//        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:APP_NAME message:NSLocalizedString(@"Formato email", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)loginButtonTouchHandler:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [UserIP loginWithFacebook];
}

- (void)logInWithFacebookResult:(NSError *)error
{
    if (error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        [error manageError];
    }
    else [UserIP setDevice];
}

- (void)setDeciveResult:(NSError *)error
{
    if (error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        [error manageError];
    }
    else [ObjectIP saveAllObjectsFromDB];
}

- (void)saveAllObjectsFromDBresult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];      // Si hay error guardar los objetos
    else [self goToApp];
}

- (void)goToApp
{
    UIViewController *viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
    [self presentViewController:container animated:YES completion:nil];
}

- (void)signUpResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];  // Si hay error en el registro
    else [self signInSuccess];              // Si el registro se realiza correctamente
}

- (void)signInSuccess
{
    AuthenticateEmailViewController *authenticateEmailViewController = [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
    [self.navigationController pushViewController:authenticateEmailViewController animated:YES];
    
    authenticateEmailViewController = nil;
}

# pragma mark - EZFormDelegate Methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
    [self checkValidForm];
}

@end
