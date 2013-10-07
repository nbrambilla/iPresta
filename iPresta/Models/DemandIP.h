//
//  DemandIP.h
//  iPresta
//
//  Created by Nacho on 24/09/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "CoreDataManager_CoreDataManagerExtension.h"

@class ObjectIP;
@class FriendIP;

@interface DemandIP : CoreDataManager

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) FriendIP *from;
@property (nonatomic, retain) FriendIP *to;
@property (nonatomic, retain) ObjectIP *object;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *iPrestaObjectId;

+ (void)saveAllDemandsFromDBWithBlock:(void (^)(NSError *))block;
+ (NSArray *)getMines;
+ (NSArray *)getFriends;
- (void)saveDemandToWithObject:(PFObject *)object withBlock:(void(^) (NSError *))block;

@end
