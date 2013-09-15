//
//  FriendIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager_CoreDataManagerExtension.h"

@class GiveIP;

@interface FriendIP : CoreDataManager

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) GiveIP *give;

+ (void)saveAllFriendsFromDBwithBlock:(void (^)(NSError *))block;
- (NSString *)firstLetter;
- (NSString *)getFullName;
- (NSString *)getCompareName;

@end
