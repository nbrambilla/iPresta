//
//  User.h
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@protocol UserDelegate <NSObject>
//
//@optional
//- (void)errorToLogin;
//- (void)loginOk;
//
@end

@interface User : NSObject

@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *username;
@property(strong, nonatomic) NSString *password;

+ (BOOL)existsCurrentUser;
+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (void)logOut;
+ (void)setDelegate:(id<UserDelegate>)userDelegate;
+ (id<UserDelegate>)delegate;
+ (void)save;
+ (BOOL)emailVerified;
+ (NSString *)currentUserEmail;
+ (void)setCurrentUserEmail:(NSString *)email;
+ (void)setCurrentUserUsername:(NSString *)username;

- (void)signIn;

@end
