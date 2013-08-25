//
//  UserIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol UserIPDelegate <NSObject>

@optional
- (void)logInResult:(NSError *)error;
- (void)refreshResult:(NSError *)error;
- (void)saveResult:(NSError *)error;
- (void)signUpResult:(NSError *)error;
- (void)requestPasswordResetForEmailResult:(NSError *)error;

@end

@interface UserIP : NSObject


+ (void)setDelegate:(id <UserIPDelegate>)_delegate;
+ (id <UserIPDelegate>)delegate;
+ (PFUser *)loggedUser;
+ (void)setObjectsUser:(PFUser *)user;
+ (PFUser *)objectsUser;
+ (void)setSearchUser:(PFUser *)user;
+ (PFUser *)searchUser;
+ (BOOL)objectsUserIsSet;

+ (NSString *)userId;
+ (NSString *)email;
+ (void)setEmail:(NSString *)email;
+ (BOOL)visible;
+ (void)setVisibility:(BOOL)visibility;
+ (BOOL)hasEmailVerified;

+ (void)logInWithUsername:(NSString *)username password:(NSString *)password;
+ (void)logOut;
+ (void)refresh;
+ (void)save;
+ (void)signUpWithEmail:(NSString *)email andPassword:(NSString *)password;
+ (void)requestPasswordResetForEmail:(NSString *)email;

@end
