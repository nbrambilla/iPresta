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
#import "RequestPasswordResetViewController.h"
#import "ChangeEmailViewController.h"
#import "AuthenticateEmailViewController.h"

#define CONNECTION_ERROR 100
#define LOGIN_ERROR 101
#define SIGNIN_ERROR 202
#define REQUESTPASSWORDRESET_ERROR 205
#define NOTCURRENTUSER_ERROR 206

@implementation User

static id<UserDelegate> delegate;

@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;
@synthesize emailVerified = _emailVerified;


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

- (void)setEmailVerified:(BOOL)emailVerified
{
    _emailVerified = emailVerified;
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

- (BOOL)emailVerified
{
    return _emailVerified;
}

#pragma mark - Current User Methods

+ (User *)currentUser
{
    User *currentUser = [User new];
    
    if([PFUser currentUser])
    {
        currentUser.username = [[PFUser currentUser] email];
        currentUser.email = [[PFUser currentUser] email];
        currentUser.password = [[PFUser currentUser] password];
        currentUser.emailVerified = [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue];
    }
    return currentUser;
}

- (void)checkEmailAuthentication
{
    if (self.email == [[PFUser currentUser] email])
    {
        UIViewController *viewController = (UIViewController *)delegate;
        [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(checkEmailAuthenticationResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:nil code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [User changeEmailError:error];
        
        error = nil;
    }
}

- (void)checkEmailAuthenticationResponse:(PFUser *)user error:(NSError *)error
{
    AuthenticateEmailViewController *authenticateEmailViewController = (AuthenticateEmailViewController *)delegate;
    [MBProgressHUD hideHUDForView:authenticateEmailViewController.view animated:YES];
    
    // Si hay error en el cambio de email
    if (error)
    {
        [User checkEmailAuthenticationError:error];
    }
    // Si el cambio de email se realiza correctamente
    else
    {
        [authenticateEmailViewController checkEmailAuthenticationSuccess];
    }
    
    authenticateEmailViewController = nil;
}

+ (void)save
{
    [[PFUser currentUser] saveInBackgroundWithTarget:delegate selector:@selector(saveUser)];
}

- (void)changeEmail:(NSString *)newEmail
{
    if (self.email == [[PFUser currentUser] email])
    {
        UIViewController *viewController = (UIViewController *)delegate;
        [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        
        [[PFUser currentUser] setEmail:newEmail];
        [[PFUser currentUser] setUsername:newEmail];
        
        [[PFUser currentUser] saveInBackgroundWithTarget:self selector:@selector(changeEmailResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:nil code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [User changeEmailError:error];
        
        error = nil;
    }
}

- (void)changeEmailResponse:(PFUser *)user error:(NSError *)error
{
    ChangeEmailViewController *changeEmailViewController = (ChangeEmailViewController *)delegate;
    [MBProgressHUD hideHUDForView:changeEmailViewController.view animated:YES];
    
    // Si hay error en el cambio de email
    if (error)
    {
        [User changeEmailError:error];
    }
    // Si el cambio de email se realiza correctamente
    else
    {
        
        [self setEmail:[[PFUser currentUser] email]];
        [self setUsername:[[PFUser currentUser] username]];
        
        [changeEmailViewController changeEmailSuccess];
    }
    
    changeEmailViewController = nil;
}

+ (void)logOut
{
    [PFUser logOut];
}

+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    User *currentUser = [User currentUser];
    currentUser.username = username;
    currentUser.email = username;
    currentUser.password = password;
    
    UIViewController * viewController = (UIViewController *)delegate;
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:username password:password target:[User class] selector:@selector(logInResponse:error:)];
    
    viewController = nil;
}

+ (void)requestPasswordResetForEmail:(NSString *)email
{
    UIViewController * viewController = (UIViewController *)delegate;
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    [PFUser requestPasswordResetForEmailInBackground:email target:[User class] selector:@selector(requestPasswordResetResponse:error:)];

    viewController = nil;
}

+ (void)requestPasswordResetResponse:(PFUser *)user error:(NSError *)error
{
    RequestPasswordResetViewController *requestPasswordResetViewController = (RequestPasswordResetViewController *)delegate;
    [MBProgressHUD hideHUDForView:requestPasswordResetViewController.view animated:YES];
    
    // Si hay error en la recuperación del password
    if (error)
    {
        [User requestPasswordResetError:error];
    }
    // Si la recuperación del password se realiza correctamente
    else
    {
        [requestPasswordResetViewController requestPasswordResetSuccess];
    }
    
    requestPasswordResetViewController = nil;
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
    CreateCountViewController *createCountViewController = (CreateCountViewController *)delegate;
    [MBProgressHUD showHUDAddedTo:createCountViewController.view animated:YES];
    
    PFUser *newUser = [PFUser new];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:self selector:@selector(signInResponse:error:)];
    
    newUser = nil;
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
        
        alert = nil;
        
    }
    else if ([error code] == LOGIN_ERROR)
    {
        // Error de login
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Email y/o password incorrecto/s" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

+ (void)signInError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
    else if ([error code] == SIGNIN_ERROR)
    {
        // Error de registro
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ya existe un usuario registrado con este email" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

+ (void)requestPasswordResetError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
        
    }
    else if ([error code] == REQUESTPASSWORDRESET_ERROR)
    {
        // Error de recuperación de email
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No existe un usuario registrado con este email" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

+ (void)changeEmailError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
    else if ([error code] == SIGNIN_ERROR)
    {
        // Error de registro
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ya existe un usuario registrado con este email" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
    else if ([error code] == NOTCURRENTUSER_ERROR)
    {
        // Error de registro
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No se puede cambiar el email a un usuario que no esta logueado" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

+ (void)checkEmailAuthenticationError:(NSError *)error
{
    if ([error code] == CONNECTION_ERROR)
    {
        // Error de conexíon
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error de Conexión" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

#pragma mark - Private methods


@end
