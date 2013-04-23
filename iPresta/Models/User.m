//
//  User.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "User.h"
#import "Book.h"

@implementation User

static id<UserDelegate> delegate;

@synthesize id = _id;
@synthesize name = _name;
@synthesize lastNames = _lastNames;
@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark - Public methods

-  (void)save
{
    [[PFUser currentUser] setObject:_username forKey:@"username"];
    [[PFUser currentUser] setObject:_email forKey:@"email"];
    [[PFUser currentUser] setObject:_password forKey:@"password"];
    [[PFUser currentUser] setObject:_name forKey:@"name"];
    [[PFUser currentUser] setObject:_lastNames forKey:@"email"];
    
    [[PFUser currentUser] save];
}

+ (void)logOut
{
    [PFUser logOut];
}

+ (void)logInUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password target:delegate selector:@selector(backFromLogin:)];
}

- (void)signUp
{
    PFUser *newUser = [PFUser new];
    newUser.username = self.username;
    newUser.email = self.username;
    newUser.password = self.password;
    
    [newUser signUpInBackgroundWithTarget:delegate selector:@selector(backFromSignUp)];
}

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

- (void)setName:(NSString *)name
{
    _name = name;
}

- (void)setLastNames:(NSString *)lastNames
{
    _lastNames = lastNames;
}

#pragma mark - User Getters

+ (PFUser *)currentUser
{
    return [PFUser currentUser];
}

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

- (NSString *)name
{
    return _name;
}

- (NSString *)lastNames
{
    return _lastNames;
}

#pragma mark - Private methods


@end
