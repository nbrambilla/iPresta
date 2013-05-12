//
//  User.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "User.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@implementation User

static id<UserDelegate> delegate;

@synthesize objectId = _objectId;
@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;
@synthesize emailVerified = _emailVerified;


#pragma mark - User Setters

+ (void)setDelegate:(id<UserDelegate>)userDelegate
{
    delegate = userDelegate;
}

- (void)setObjectId:(NSString *)objectId
{
    _objectId = objectId;
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

- (NSString *)objectId
{
    return _objectId;
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
        currentUser.objectId = [[PFUser currentUser] objectId];
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
    [ProgressHUD showProgressHUDIn:delegate];
    
    PFUser *newUser = [PFUser new];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:self selector:@selector(signInResponse:error:)];
    
    newUser = nil;
}

- (void)signInResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];    // Si hay error en el registro
    else                                    // Si el registro se realiza correctamente
    {
        if ([delegate respondsToSelector:@selector(signInSuccess)])
        {
            [delegate signInSuccess];
        }
    }
}

#pragma mark - LogIn Methods

+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    User *currentUser = [User currentUser];
    currentUser.username = username;
    currentUser.email = username;
    currentUser.password = password;
    
    [PFUser logInWithUsernameInBackground:username password:password target:[User class] selector:@selector(logInResponse:error:)];
}

+ (void)logInResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];      // Si hay error en el login
    else                                            // Si el login se realiza correctamente
    {
        if ([delegate respondsToSelector:@selector(logInSuccess)])
        {
            [delegate logInSuccess];
        }
    }
}

#pragma mark - Reset Password Methods

+ (void)requestPasswordResetForEmail:(NSString *)email
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    [PFUser requestPasswordResetForEmailInBackground:email target:[User class] selector:@selector(requestPasswordResetResponse:error:)];
}

+ (void)requestPasswordResetResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];  // Si hay error en la recuperación del password
    else                                        // Si la recuperación del password se realiza correctamente
    {
        [[User currentUser] setPassword:[[PFUser currentUser] password]];
        
        if ([delegate respondsToSelector:@selector(requestPasswordResetSuccess)])
        {
            [delegate requestPasswordResetSuccess];
        }
    }
}

#pragma mark - Check Email Authentication Methods

- (void)checkEmailAuthentication
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    if (self.email == [[PFUser currentUser] email])
    {
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(checkEmailAuthenticationResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"error" code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [error manageErrorTo:delegate];
        
        error = nil;
    }
}

- (void)checkEmailAuthenticationResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];    // Si hay error en el cambio de email
    else                                    // Si el cambio de email se realiza correctamente
    {
        if ([delegate respondsToSelector:@selector(checkEmailAuthenticationSuccess)])
        {
            [delegate checkEmailAuthenticationSuccess];
        }
    }
    
}

#pragma mark - Resend Authenticate Message Methods

- (void)resendAuthenticateMessage
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    if (self.email == [[PFUser currentUser] email])
    {
        [[PFUser currentUser] setEmail:self.email];
        
        [[PFUser currentUser] saveInBackgroundWithTarget:self selector:@selector(resendAuthenticateMessageResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"error" code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [error manageErrorTo:delegate];
        
        error = nil;
    }
}

- (void)resendAuthenticateMessageResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];     // Si hay error en el cambio de email
    else                                     // Si el cambio de email se realiza correctamente
    {
        if ([delegate respondsToSelector:@selector(resendAuthenticateMessageSuccess)])
        {
            [delegate resendAuthenticateMessageSuccess];
        }
    }
}

#pragma mark - Change Email Methods

- (void)changeEmail:(NSString *)newEmail
{
    if (self.email == [[PFUser currentUser] email])
    {
        [ProgressHUD showProgressHUDIn:delegate];
        
        [[PFUser currentUser] setEmail:newEmail];
        [[PFUser currentUser] setUsername:newEmail];
        
        [[PFUser currentUser] saveInBackgroundWithTarget:self selector:@selector(changeEmailResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"error" code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [error manageErrorTo:delegate];
        
        error = nil;
    }
}

- (void)changeEmailResponse:(PFUser *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) // Si hay error en el cambio de email
    {
        [[PFUser currentUser] setEmail:self.email];
        [[PFUser currentUser] setUsername:self.email];
        
        [error manageErrorTo:delegate];
    }
    else // Si el cambio de email se realiza correctamente
    {
        [[User currentUser] setEmail:[[PFUser currentUser] email]];
        [[User currentUser] setUsername:[[PFUser currentUser] username]];
        
        if ([delegate respondsToSelector:@selector(changeEmailSucess)])
        {
            [delegate changeEmailSuccess];
        }
    }
}

@end
