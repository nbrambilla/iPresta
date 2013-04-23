//
//  CreateCountViewController.m
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CreateCountViewController.h"
#import "MBProgressHUD.h"

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

- (void)viewDidUnload {
    emailTextField = nil;
    passwordTextField = nil;
    repeatPasswordTextField = nil;
    [super viewDidUnload];
}

#pragma mark - Button Functions

- (IBAction)createCount:(id)sender
{
    if ([self isValidEmail])
    {
        if ([self paswordsMatch])
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [User logOut];
            
            User *newUser = [User new];
            newUser.username = emailTextField.text;
            newUser.email = emailTextField.text;
            newUser.password = passwordTextField.text;
            
            [newUser signUp];
        }
    }
}

#pragma mark - SignUp Functions

- (void)backFromSignUp
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([User currentUser] != nil)
    {
        [self signUpOk];
    }
    else
    {
        [self errorToSignUp];
    }
}

- (void)errorToSignUp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)signUpOk
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Usuario creado!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
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

- (BOOL)isValidEmail
{
    BOOL bReturn;
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    bReturn = [emailTest evaluateWithObject:emailTextField.text];
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Email no válido" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        bReturn = NO;
    }
    
    return  bReturn;
}

@end
