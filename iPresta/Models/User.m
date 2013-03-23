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

static User *loggedUser = nil;

@synthesize delegate = _delegate;
@synthesize id = _id;
@synthesize name = _name;
@synthesize lastNames = _lastNames;
@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark - Public methods

+ (User *)loggedUser
{
    @synchronized(self){
        if (!loggedUser) {
            loggedUser = [self new];
        }
    }
    return loggedUser;
}

- (id)initWithUsermame:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {
        
        if ([User existsUserwithUsername:username]) {
            [self logInWithUsername:username andPassword:password];
        } else {
            [self signInWithUsername:username andPassword:password];
        }
    }
    loggedUser = self;
    
    return self;
}

-  (void)save
{
    [currentUser save];
}

#pragma mark - User Setters

- (void)setUsername:(NSString *)username
{
    _username = username;
    [currentUser setObject:username forKey:@"username"];
}

- (void)setEmail:(NSString *)email
{
    _email = email;
    currentUser.email = email;
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    currentUser.password = password;
}

- (void)setName:(NSString *)name
{
    _name = name;
    [currentUser setObject:name forKey:@"name"];
}

- (void)setLastNames:(NSString *)lastNames
{
    _lastNames = lastNames;
    [currentUser setObject:lastNames forKey:@"lastNames"];
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

- (NSString *)name
{
    return _name;
}

- (NSString *)lastNames
{
    return _lastNames;
}

#pragma mark - Private methods

+ (BOOL)existsUserwithUsername:(NSString *)username
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    
    return ([query countObjects] > 0);
}

- (void)logInWithUsername:(NSString *)username andPassword:(NSString *)password
{
    NSError *error;
    [PFUser logInWithUsername:username password:password error:&error];
    
    if (!error) {
        currentUser = [PFUser currentUser];
    } else {
        if ([_delegate respondsToSelector:@selector(errorToSaveUser)]) {
            [_delegate errorToSaveUser];
        }
    }
}

- (void)signInWithUsername:(NSString *)username andPassword:(NSString *)password
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    NSError *error;
    [user signUp:&error];
    
    if (!error) {
        currentUser = [PFUser currentUser];
    } else {
        if ([_delegate respondsToSelector:@selector(errorToSaveUser)]) {
            [_delegate errorToSaveUser];
        }
    }

}

@end
