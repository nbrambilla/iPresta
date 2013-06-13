//
//  User.h
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "iPrestaObject.h"

@interface User : PFUser<PFSubclassing>

@property(retain) NSString *objectId;
@property(retain, nonatomic) NSString *email;
@property(retain, nonatomic) NSString *username;
@property(retain, nonatomic) NSString *password;
@property(retain, nonatomic) NSMutableArray *objectsArray;

+ (BOOL)currentUserHasEmailVerified;
+ (User *)currentUser;
- (BOOL)hasObject:(iPrestaObject *)object;

@end
