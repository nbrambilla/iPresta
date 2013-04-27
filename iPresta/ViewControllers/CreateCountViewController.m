//
//  CreateCountViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CreateCountViewController.h"
#import "AuthenticateEmailViewController.h"
#import "iPrestaNavigationController.h"
#import "MBProgressHUD.h"
#import "iPrestaNSString.h"

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
    
    [User setDelegate:self];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark - Button Functions

- (IBAction)createCount:(id)sender
{
    if ([emailTextField.text isValidEmail])
    {
        if ([passwordTextField.text isValidPassword])
        {
            if ([self paswordsMatch])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                User *newUser = [User new];
                newUser.username = emailTextField.text;
                newUser.email = emailTextField.text;
                newUser.password = passwordTextField.text;
                
                [newUser signIn];
            }
        }
    }
}

#pragma mark - SignUp Functions

- (void)backFromSignUp:(PFUser *)user error:(NSError *)error
{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    
//    if (error)
//    {
//        [User signInError:error];
//    }
//    else
//    {
//        [self signUpOk];
//    }
}

- (void)signInSuccess
{
    UIViewController *viewController;
    UINavigationController *navigationController;
    
    navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
    viewController =  [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
    [navigationController pushViewController:viewController animated:NO];
    
    [self presentModalViewController:navigationController animated:YES];
    
    viewController = nil;
    navigationController = nil;
}

#pragma mark - Check Fields Functions

- (BOOL)paswordsMatch
{
    BOOL bReturn = ([passwordTextField.text isEqualToString:repeatPasswordTextField.text] && [passwordTextField.text length] > 0);
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Las contraseñas son diferentes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    return bReturn;
}

@end
