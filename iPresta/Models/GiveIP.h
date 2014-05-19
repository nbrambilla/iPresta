//
//  GiveIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CoreDataManager_CoreDataManagerExtension.h"

@class FriendIP;
@class ObjectIP;

@protocol GiveIPDelegate <NSObject>

@optional

- (void)giveError:(NSError *)error;
- (void)extendGiveSuccess;

@end

@interface GiveIP : CoreDataManager

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dateBegin;
@property (nonatomic, retain) NSDate * dateEnd;
@property (nonatomic, retain) ObjectIP *object;
@property (nonatomic, retain) FriendIP *to;
@property (nonatomic, retain) FriendIP *from;
@property (nonatomic, retain) NSNumber *actual;
@property (nonatomic, retain) NSString *iPrestaObjectId;

+ (void)saveAllGivesFromDBWithBlock:(void (^)(NSError *))block;
+ (void)addGivesFromDB;
+ (void)deleteAllGivesFromDBObject:(PFObject *)dbObject andObject:(ObjectIP *)object withBlock:(void (^)(NSError *))block;
+ (void)setDelegate:(id <GiveIPDelegate>)_delegate;
+ (id <GiveIPDelegate>)delegate;
+ (NSArray *)getMines;
+ (NSArray *)getFriends;
+ (NSArray *)getMinesExpired;
+ (NSArray *)getFriendsExpired;
+ (NSArray *)getMinesInTime;
+ (NSArray *)getFriendsInTime;
+ (void)refreshActuals;

- (BOOL)isExpired;
- (void)extendGive:(NSInteger)date;
- (void)saveToObject:(PFObject *)object to:(id)to WithBlock:(void(^) (NSError *))block;
- (void)cancelWithBlock:(void(^) (NSError *))block;
- (void)sendGivePushResponseWithBlock:(void (^)(NSError *))block;

@end
