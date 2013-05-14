//
//  User.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "User.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@implementation User

static id<UserDelegate> delegate;

@dynamic objectId;
@dynamic email;
@dynamic username;
@dynamic password;

#pragma mark - User Setters

+ (void)setDelegate:(id<UserDelegate>)userDelegate
{
    delegate = userDelegate;
}

#pragma mark - User Getters

+ (id<UserDelegate>)delegate
{
    return delegate;
}

#pragma mark - Class Methods

+ (User *)currentUser
{
    User *currentUser = nil;
    
    if([PFUser currentUser])
    {
        currentUser = [User object];
        currentUser.objectId = [[PFUser currentUser] objectId];
        currentUser.username = [[PFUser currentUser] email];
        currentUser.email = [[PFUser currentUser] email];
        currentUser.password = [[PFUser currentUser] password];
    }
    return currentUser;
}

+ (BOOL)currentUserHasEmailVerified
{
    return [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue];
}

+ (void)logOut
{
    [User logOut];
}

#pragma mark - SignIn Methods

- (void)signIn
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    User *newUser = [User object];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:self selector:@selector(signInResponse:error:)];
    
    newUser = nil;
}

- (void)signInResponse:(User *)user error:(NSError *)error
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
    
    [User logInWithUsernameInBackground:username password:password target:[User class] selector:@selector(logInResponse:error:)];
}

+ (void)logInResponse:(User *)user error:(NSError *)error
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
    
    [User requestPasswordResetForEmailInBackground:email target:[User class] selector:@selector(requestPasswordResetResponse:error:)];
}

+ (void)requestPasswordResetResponse:(User *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];  // Si hay error en la recuperación del password
    else                                        // Si la recuperación del password se realiza correctamente
    {
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
    
    if (self.email == [[User currentUser] email])
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

- (void)checkEmailAuthenticationResponse:(User *)user error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];  // Si hay error en el cambio de email
    else                                        // Si el cambio de email se realiza correctamente
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
    
    if (self.email == [[User currentUser] email])
    {
        //[[PFUser currentUser] setEmail:self.email];
        
        [[User currentUser] saveInBackgroundWithTarget:self selector:@selector(resendAuthenticateMessageResponse:error:)];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"error" code:NOTCURRENTUSER_ERROR userInfo:nil];
        
        [error manageErrorTo:delegate];
        
        error = nil;
    }
}

- (void)resendAuthenticateMessageResponse:(User *)user error:(NSError *)error
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
    if (self.email == [[User currentUser] email])
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

- (void)changeEmailResponse:(User *)user error:(NSError *)error
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
        
        if ([delegate respondsToSelector:@selector(changeEmailSuccess)])
        {
            [delegate changeEmailSuccess];
        }
    }
}

@end
