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

@end
