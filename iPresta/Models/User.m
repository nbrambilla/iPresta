//
//  User.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "User.h"
#import "Book.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "CreateCountViewController.h"

#define CONNECTION_ERROR 100
#define LOGIN_ERROR 101
#define SIGNIN_ERROR 202

@implementation User

static id<UserDelegate> delegate;

@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark - User Setters

- (void)setUsername:(NSString *)username
{
    _username = username;
}

- (void)setEmail:(NSString *)email
{
    _email = email;
}

- (void)setPassword:(NSString *)password
{
    _password = password;
}

#pragma mark - User Getters

- (NSString *)username
{
    return _username;
}

- (NSString *)email
{
    return _email;
}

- (NSString *)password
{
    return _password;
}

#pragma mark - Current User Methods

+ (void)save
{
    [[PFUser currentUser] saveInBackgroundWithTarget:delegate selector:@selector(saveUser)];
}

+ (void)logOut
{
    [PFUser logOut];
}

+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    UIViewController * viewController = (UIViewController *)delegate;
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:username password:password target:[User class] selector:@selector(logInResponse:error:)];
    
    viewController = nil;
}

+ (void)logInResponse:(PFUser *)user error:(NSError *)error
{
    LoginViewController *loginViewController = (LoginViewController *)delegate;
    [MBProgressHUD hideHUDForView:loginViewController.view animated:YES];
    
    // Si hay error en el login
    if (error)
    {
        [User logInError:error];
    }
    // Si el login se realiza correctamente
    else
    {
        [loginViewController logInSuccess];
    }
    
    loginViewController = nil;
}

- (void)signIn
{
    PFUser *newUser = [PFUser new];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:self selector:@selector(signInResponse:error:)];
}

- (void)signInResponse:(PFUser *)user error:(NSError *)error
{
    CreateCountViewController *createCountViewController = (CreateCountViewController *)delegate;
    [MBProgressHUD hideHUDForView:createCountViewController.view animated:YES];
    
    // Si hay error en el registro
    if (error)
    {
        [User signInError:error];
    }
    // Si el registro se realiza correctamente
    else
    {
        [createCountViewController signInSuccess];
    }
    
    createCountViewController = nil;
}

+ (BOOL)existsCurrentUser
{
    return ([PFUser currentUser] != nil);
}

+ (BOOL)emailVerified
{
    return [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue];
}

+ (NSString *)currentUserEmail
{
    return [[PFUser currentUser] objectForKey:@"email"];
}

+ (void)setCurrentUserEmail:(NSString *)email
{
    [[PFUser currentUser] setEmail:email];
}

+ (void)setCurrentUserUsername:(NSString *)username
{
    [[PFUser currentUser] setUsername:username];
}

+ (void)setDelegate:(id<UserDelegate>)userDelegate
{
    delegate = userDelegate;
}

+ (id<UserDelegate>)delegate
{
    return delegate;
}

+ (void)logInError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else if ([error code] == LOGIN_ERROR)
    {
        // Error de login
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Email y/o password incorrecto/s" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

+ (void)signInError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else if ([error code] == SIGNIN_ERROR)
    {
        // Error de registro
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ya existe un usuario registrado con este email" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

#pragma mark - Private methods


@end
