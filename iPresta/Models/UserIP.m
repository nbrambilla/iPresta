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

+ (BOOL)isNew
{
    return ![[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue] || [[PFUser currentUser] isNew] ;
}

#pragma mark - Asychronous Methods

+ (void)logInWithUsername:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if (!error)
        {
            [[PFInstallation currentInstallation] setObject:[NSNumber numberWithBool:YES] forKey:@"isLogged"];
            
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
    
    if (!FBSession.activeSession.isOpen)
    {
        NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
        [FBSession openActiveSessionWithReadPermissions:permissionsArray allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            if (!error) {
                [FBSession setActiveSession:session];
                [UserIP logFacebookUser];
            }
        }];
    }
    else [UserIP logFacebookUser];
}

+ (void)logFacebookUser
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (!error) {
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"email" equalTo:[user objectForKey:@"email"]];
            [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error)
                {
                    PFUser *user= (PFUser *)object;
                    
                    if (user)
                    {
                        if (![UserIP isFacebookUser:user]) {
                            error = [[NSError alloc] initWithCode:FBLOGINUSEREXISTS_ERROR userInfo:@{@"email":[user objectForKey:@"email"]}];
                            if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
                        }
                        else
                        {
                            [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error)
                            {
                                [user setObject:[NSNumber numberWithBool:YES] forKey:@"isFacebookUser"];
                                
                                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
                                }];
                            }];
                        }
                    }
                    else
                    {
                        [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error)
                        {
                            if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
                        }];
                    }
                }
                else if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
            }];
        }
        
        else
        {
            error = [[NSError alloc] initWithCode:FBLOGIN_ERROR userInfo:nil];
            if ([delegate respondsToSelector:@selector(logInResult:)]) [delegate logInResult:error];
        }
    }];
}

+ (void)linkWithFacebook:(BOOL)link
{
    
    if (link)
    {
        NSArray *permissionsArray = @[@"user_about_me", @"publish_stream", @"publish_actions",@"email"];

        [PFFacebookUtils linkUser:[UserIP loggedUser] permissions:permissionsArray block:^(BOOL succeeded, NSError *error)
        {
            [[UserIP loggedUser] setObject:[NSNumber numberWithBool:YES] forKey:@"isFacebookUser"];
            [[UserIP loggedUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if ([delegate respondsToSelector:@selector(linkWithFacebookResult:)]) [delegate linkWithFacebookResult:error];
            }];
        }];
    }
    else
    {
        [PFFacebookUtils unlinkUserInBackground:[UserIP loggedUser] block:^(BOOL succeeded, NSError *error)
         {
             [[UserIP loggedUser] setObject:[NSNumber numberWithBool:NO] forKey:@"isFacebookUser"];
             [[UserIP loggedUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if ([delegate respondsToSelector:@selector(linkWithFacebookResult:)]) [delegate linkWithFacebookResult:error];
             }];
         }];
    }
}

+ (void)logOut
{
    [[PFInstallation currentInstallation] setObject:[NSNumber numberWithBool:NO] forKey:@"isLogged"];
    
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [PFUser logOut];
        
        if ([delegate respondsToSelector:@selector(logOutResult:)]) [delegate logOutResult:error];
    }];
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

+ (void)setDevice
{
    if ([PFInstallation currentInstallation])
    {
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        
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
    return [[user objectForKey:@"isFacebookUser"] boolValue];
}

@end
