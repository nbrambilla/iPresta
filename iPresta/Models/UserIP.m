//
//  UserIP.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"
#import "UserIP.h"

static id <UserIPDelegate> delegate;

@implementation UserIP

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
    return [[PFUser currentUser] objectForKey:@"objectId"];
}

+ (NSString *)email
{
    return [[PFUser currentUser] objectForKey:@"email"];
}

+ (void)setEmail:(NSString *)email
{
    [[PFUser currentUser] setEmail:email];
    [[PFUser currentUser] setUsername:email];
}

+ (BOOL)visible
{
    return [[[PFUser currentUser] objectForKey:@"visible"] boolValue];
}

+ (void)setVisibility:(BOOL)visibility
{
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:visibility] forKey:@"visible"];
}

+ (BOOL)hasEmailVerified
{
    return [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue];
}

#pragma mark - Asychronous Methods

+ (void)logInWithUsername:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
    }];    
}

+ (void)logOut
{
    [PFUser logOut];
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
    [user setObject:[NSNumber numberWithBool:YES] forKey:@"visible"];
    
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
    [query whereKey:@"email" equalTo:email];
    
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

@end
