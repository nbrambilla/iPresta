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

@dynamic objectId;
@dynamic email;
@dynamic username;
@dynamic password;

#pragma mark - Class Methods

+ (User *)currentUser
{
//    User *currentUser = nil;
//    
//    if([PFUser currentUser])
//    {
//        currentUser = [User object];
//        currentUser.objectId = [[PFUser currentUser] objectId];
//        currentUser.username = [[PFUser currentUser] email];
//        currentUser.email = [[PFUser currentUser] email];
//        currentUser.password = [[PFUser currentUser] password];
//    }
//    return currentUser;
    return (User *)[PFUser currentUser];
}

+ (BOOL)currentUserHasEmailVerified
{
    return [[[User currentUser] objectForKey:@"emailVerified"] boolValue];
}

@end
