//
//  UserIP.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"
#import "FriendIP.h"
#import "UserIP.h"
#import "ObjectIP.h"
#import "Facebook.h"

@implementation UserIP

static id <UserIPDelegate> delegate;
static PFUser *objectsUser;
static PFUser *searchUser;

#pragma mark - Class Methods

+ (void)setDelegate:(id <UserIPDelegate>)_delegate
{
    delegate = _delegate;
}

+ (id <UserIPDelegate>)delegate
{
    return delegate;
}

+ (PFUser *)loggedUser
{
    return [PFUser currentUser];
}

+ (void)setObjectsUser:(PFUser *)user
{
    objectsUser = user;
}

+ (PFUser *)objectsUser
{
    return (objectsUser) ? objectsUser : [PFUser currentUser];
}

+ (void)setSearchUser:(PFUser *)user
{
    searchUser = user;
}

+ (PFUser *)searchUser
{
    return searchUser;
}

+ (BOOL)objectsUserIsSet
{
    return (![[UserIP objectsUser] isEqual:[UserIP loggedUser]]);
}

#pragma mark - Setter & Getters

+ (NSString *)userId
{
    return [[PFUser currentUser] objectId];
}

+ (NSString *)email
{
    return [[PFUser currentUser] email];
}

+ (void)setEmail:(NSString *)email
{
    [[PFUser currentUser] setEmail:email];
    [[PFUser currentUser] setUsername:email];
}

+ (BOOL)visible
{
    return [[PFUser currentUser][@"visible"] boolValue];
}

+ (void)setVisibility:(BOOL)visibility
{
    [[PFUser currentUser] setObject:@(visibility) forKey:@"visible"];
}

+ (BOOL)hasEmailVerified
{
    return [[PFUser currentUser][@"emailVerified"] boolValue];
}

+ (BOOL)isNew
{
    return ![[PFUser currentUser][@"emailVerified"] boolValue] || [[PFUser currentUser] isNew];
}

#pragma mark - Asychronous Methods

+ (void)logInWithUsername:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if (!error)
        {
            [[PFInstallation currentInstallation] setObject:@YES forKey:@"isLogged"];
            
            [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
            }];
        }
        else if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
    }];
}

+ (void)loginWithFacebook
{
    Facebook *facebook = [Facebook new];
    
    [facebook login:^(NSError *error)
    {
        if ([delegate respondsToSelector:@selector(logInWithFacebookResult:)]) [delegate logInWithFacebookResult:error];
    }];
}

+ (void)linkWithFacebook:(BOOL)link
{
    Facebook *facebook = [Facebook new];
    
    [facebook link:link block:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(linkWithFacebookResult:)]) [delegate linkWithFacebookResult:error];
    }];
}

+ (void)shareInFacebook:(NSString *)text block:(void (^)(NSError *))block
{
    Facebook *facebook = [Facebook new];
    [facebook shareText:text block:^(NSError *error)
    {
        block(error);
    }];
}

+ (void)logOut
{
    if ([PFInstallation currentInstallation][@"deviceToken"])
    {
        [[PFInstallation currentInstallation] setObject:@NO forKey:@"isLogged"];
        [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [PFUser logOut];
            if ([delegate respondsToSelector:@selector(logOutResult:)]) [delegate logOutResult:error];
        }];
    }
    else
    {
        [PFUser logOut];
        if ([delegate respondsToSelector:@selector(logOutResult:)]) [delegate logOutResult:nil];
    }
}

+ (void)refresh
{
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if ([delegate respondsToSelector:@selector(refreshResult:)]) [delegate refreshResult:error];
    }];
}

+ (void)save
{
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error)
    {
         if ([delegate respondsToSelector:@selector(saveResult:)]) [delegate saveResult:error];
    }];
}

+ (void)signUpWithEmail:(NSString *)email andPassword:(NSString *)password
{
    // Se crea un nuevo usuario
                
    PFUser *user = [PFUser object];
    [user setUsername:email];
    [user setEmail:email];
    [user setPassword:password];
    [user setObject:@NO forKey:@"isFacebookUser"];
    [user setObject:@YES forKey:@"visible"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if ([delegate respondsToSelector:@selector(signUpResult:)]) [delegate signUpResult:error];
    }];
}

+ (void)requestPasswordResetForEmail:(NSString *)email
{
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error)
    {
        if ([delegate respondsToSelector:@selector(requestPasswordResetForEmailResult:)]) [delegate requestPasswordResetForEmailResult:error];
    }];
}

+ (void)getDBUserWithEmail:(NSString *)email
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:email];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
    {
         if (!error) // Si se obtienen los usuarios, se buscan en los registros
         {
             if([users count] > 0)
             {
                 if ([delegate respondsToSelector:@selector(getDBUserWithEmailSuccess:withError:)])
                 {
                     [delegate getDBUserWithEmailSuccess:[users objectAtIndex:0] withError:nil];
                 }
             }
             else
             {
                 if ([delegate respondsToSelector:@selector(getDBUserWithEmailSuccess:withError:)])
                 {
                     [delegate getDBUserWithEmailSuccess:nil withError:nil];
                 }
             }
         }
         else
         {
             if ([delegate respondsToSelector:@selector(getDBUserWithEmailSuccess:withError:)])
             {
                 [delegate getDBUserWithEmailSuccess:nil withError:error];
             }
         }
    }];
}

+ (void)setDevice
{
    if ([PFInstallation currentInstallation][@"deviceToken"])
    {
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] setObject:@YES forKey:@"isLogged"];
        [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if ([delegate respondsToSelector:@selector(setDeciveResult:)]) [delegate setDeciveResult:error];
        }];
    }
    else if ([delegate respondsToSelector:@selector(setDeciveResult:)]) [delegate setDeciveResult:nil];
}

# pragma mark - Public Methods

+ (BOOL)hasObject:(ObjectIP *)object
{
    NSArray *allObjects = [ObjectIP getAll];
    
    for (ObjectIP *selectedObject in allObjects)
    {
        if ([object isEqualToObject:selectedObject]) return YES;
    }
    
    return NO;
}

+ (BOOL)isLinkedToFacebook
{
    return [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
}

+ (BOOL)isFacebookUser:(PFUser *)user
{
    return [user[@"isFacebookUser"] boolValue];
}

@end
