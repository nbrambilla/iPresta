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

#define CONNECTION_ERROR 100
#define LOGIN_ERROR 101
#define SIGNIN_ERROR 202
#define REQUESTPASSWORDRESET_ERROR 205
#define NOTCURRENTUSER_ERROR 700

@implementation User

static id<UserDelegate> delegate;

@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;
@synthesize emailVerified = _emailVerified;


#pragma mark - User Setters

+ (void)setDelegate:(id<UserDelegate>)userDelegate
{
    delegate = userDelegate;
}

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

+ (id<UserDelegate>)delegate
{
    return delegate;
}

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

#pragma mark - Class Methods

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

+ (void)logOut
{
    [PFUser logOut];
}

+ (BOOL)existsCurrentUser
{
    return ([[User currentUser] email] != nil);
}

#pragma mark - SignIn Methods

- (void)signIn
{
    [User showProgressHUD];
    
    PFUser *newUser = [PFUser new];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:self selector:@selector(signInResponse:error:)];
    
    newUser = nil;
}

- (void)signInResponse:(PFUser *)user error:(NSError *)error
{
    UIViewController *viewController = (UIViewController *)delegate;
    [MBProgressHUD hideHUDForView:viewController.view.window animated:YES];
    
    if (error) [User manageError:error];    // Si hay error en el registro
    else [delegate signInSuccess];          // Si el registro se realiza correctamente
    
    viewController = nil;
}

#pragma mark - LogIn Methods

+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [User showProgressHUD];
    
    User *currentUser = [User currentUser];
    currentUser.username = username;
    currentUser.email = username;
    currentUser.password = password;
    
    [PFUser logInWithUsernameInBackground:username password:password target:[User class] selector:@selector(logInResponse:error:)];
}

+ (void)logInResponse:(PFUser *)user error:(NSError *)error
{
    [User hideProgressHUD];
    
    if (error) [User manageError:error];    // Si hay error en el login
    else [delegate logInSuccess];           // Si el login se realiza correctamente
}

#pragma mark - Reset Password Methods

+ (void)requestPasswordResetForEmail:(NSString *)email
{
    [User showProgressHUD];
    
    [PFUser requestPasswordResetForEmailInBackground:email target:[User class] selector:@selector(requestPasswordResetResponse:error:)];
}

+ (void)requestPasswordResetResponse:(PFUser *)user error:(NSError *)error
{
    [User hideProgressHUD];
    
    if (error) [User manageError:error];        // Si hay error en la recuperación del password
    else {                                      // Si la recuperación del password se realiza correctamente
        [[User currentUser] setPassword:[[PFUser currentUser] password]];
        
        [delegate requestPasswordResetSuccess];
    }
}

#pragma mark - Check Email Authentication Methods

- (void)checkEmailAuthentication
{
    [User showProgressHUD];
    
    if (self.email == [[PFUser currentUser] email])
    {
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(checkEmailAuthenticationResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:nil code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [User manageError:error];
        
        error = nil;
    }
}

- (void)checkEmailAuthenticationResponse:(PFUser *)user error:(NSError *)error
{
    [User hideProgressHUD];
    
    if (error) [User manageError:error];                // Si hay error en el cambio de email
    else [delegate checkEmailAuthenticationSuccess];    // Si el cambio de email se realiza correctamente
    
}

#pragma mark - Resend Authenticate Message Methods

- (void)resendAuthenticateMessage
{
    [User showProgressHUD];
    
    if (self.email == [[PFUser currentUser] email])
    {
        [[PFUser currentUser] setEmail:self.email];
        
        [[PFUser currentUser] saveInBackgroundWithTarget:self selector:@selector(resendAuthenticateMessageResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:nil code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [User manageError:error];
        
        error = nil;
    }
}

- (void)resendAuthenticateMessageResponse:(PFUser *)user error:(NSError *)error
{
    [User hideProgressHUD];
    
    if (error) [User manageError:error];                 // Si hay error en el cambio de email
    else [delegate resendAuthenticateMessageSuccess];    // Si el cambio de email se realiza correctamente
}

#pragma mark - Change Email Methods

- (void)changeEmail:(NSString *)newEmail
{
    if (self.email == [[PFUser currentUser] email])
    {
        [User showProgressHUD];
        
        [[PFUser currentUser] setEmail:newEmail];
        [[PFUser currentUser] setUsername:newEmail];
        
        [[PFUser currentUser] saveInBackgroundWithTarget:self selector:@selector(changeEmailResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:nil code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [User manageError:error];
        
        error = nil;
    }
}

- (void)changeEmailResponse:(PFUser *)user error:(NSError *)error
{
    [User hideProgressHUD];
    
    if (error) // Si hay error en el cambio de email
    {
        [[PFUser currentUser] setEmail:self.email];
        [[PFUser currentUser] setUsername:self.email];
        
        [User manageError:error]; 
    }
    else // Si el cambio de email se realiza correctamente
    {
        [[User currentUser] setEmail:[[PFUser currentUser] email]];
        [[User currentUser] setUsername:[[PFUser currentUser] username]];
        
        [delegate changeEmailSuccess];
    }
}

#pragma mark - Manage Errors Methods

+ (void)manageError:(NSError *)error
{
    NSString *message;
    
    switch ([error code]) {
        case CONNECTION_ERROR: // Error de conexión
            message = @"Error de Conexión";
            break;
        case LOGIN_ERROR: // Error de Login
            message = @"Email y/o password incorrecto/s";
            break;
        case SIGNIN_ERROR: // Error de registro
            message = @"Ya existe un usuario registrado con este email";
            break;
        case REQUESTPASSWORDRESET_ERROR: // Error de recuperación de email
            message = @"No existe un usuario registrado con este email";
            break;
        case NOTCURRENTUSER_ERROR: // Error al modificar un usuario que no es el logueado
            message = @"No se puede modificar los datos de un usuario que no esta logueado";
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}

#pragma mark - ProgressHUD Methods

+ (void)showProgressHUD
{
    UIViewController *viewController = (UIViewController *)delegate;
    [MBProgressHUD showHUDAddedTo:viewController.view.window animated:YES];
    
    viewController = nil;
}

+ (void)hideProgressHUD
{
    UIViewController *viewController = (UIViewController *)delegate;
    [MBProgressHUD hideHUDForView:viewController.view.window animated:YES];
    
    viewController = nil;
}

@end
