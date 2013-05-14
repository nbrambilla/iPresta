//
//  User.h
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@class iPrestaObject;

@protocol UserDelegate <NSObject>

@optional
- (void)logInSuccess;
- (void)signInSuccess;
- (void)requestPasswordResetSuccess;
- (void)checkEmailAuthenticationSuccess;
- (void)resendAuthenticateMessageSuccess;
- (void)changeEmailSuccess;

@end

@interface User : PFUser<PFSubclassing>

@property(retain) NSString *objectId;
@property(retain, nonatomic) NSString *email;
@property(retain, nonatomic) NSString *username;
@property(retain, nonatomic) NSString *password;

+ (BOOL)currentUserHasEmailVerified;
+ (User *)currentUser;
+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (void)logOut;
+ (void)setDelegate:(id<UserDelegate>)userDelegate;
+ (id<UserDelegate>)delegate;
+ (void)requestPasswordResetForEmail:(NSString *)email;

- (void)checkEmailAuthentication;
- (void)changeEmail:(NSString *)newEmail;
- (void)signIn;
- (void)resendAuthenticateMessage;

@end
