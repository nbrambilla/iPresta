//
//  User.h
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@protocol UserDelegate <NSObject>

- (void)errorToSaveUser;

@end

@interface User : NSObject {
    PFUser *currentUser;
}

@property(nonatomic) id<UserDelegate> delegate;
@property(strong, nonatomic) NSString *id;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *lastNames;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *username;
@property(strong, nonatomic) NSString *password;

+ (User *)loggedUser;
- (id)initWithUsermame:(NSString *)username password:(NSString *)password;
- (void)save;

@end
