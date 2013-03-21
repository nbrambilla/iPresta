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

@synthesize delegate = _delegate;
@synthesize name = _name;
@synthesize lastNames = _lastNames;
@synthesize email = _email;
@synthesize username = _username;
@synthesize password = _password;

+ (User *)loggedUser
{
    static User *shared = nil;
    @synchronized(self){
        if (!shared) {
            shared = [self new];
        }
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        if (currentUser) {
            currentUser = [PFUser currentUser];
        } else {
            currentUser = [PFUser user];
        }
    }
    return self;
}

- (BOOL)signIn
{
    BOOL isUserSaved = YES;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.email];
    
    NSError *error;
    
    if ([query countObjects]) {
        [PFUser logInWithUsername:self.username password:self.password error:&error];
        
        if (!error) {
            isUserSaved = YES;
        } else {
            
            isUserSaved = NO;
            
            if ([_delegate respondsToSelector:@selector(errorToSaveUser)]) {
                [_delegate errorToSaveUser];
            }
        }
    } else {
        [currentUser signUp:&error];
        
        if (!error) {
            isUserSaved = YES;
        } else {
            
            isUserSaved = NO;
            
            if ([_delegate respondsToSelector:@selector(errorToSaveUser)]) {
                [_delegate errorToSaveUser];
            }
        }
    }
    self.username = @"nnbram";
    self.name = @"nnbram";
    [currentUser save];
    return isUserSaved;
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
    return currentUser.username;
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


@end
