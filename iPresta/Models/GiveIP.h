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
@property (nonatomic, retain) ObjectIP *objectIP;
@property (nonatomic, retain) FriendIP *friend;
@property (nonatomic, retain) NSNumber *actual;

+ (void)saveAllGivesFromDBObject:(PFObject *)object withBlock:(void (^)(NSError *))block;
+ (void)deleteAllGivesFromDBObject:(PFObject *)dbObject andObject:(ObjectIP *)object withBlock:(void (^)(NSError *))block;
+ (void)setDelegate:(id <GiveIPDelegate>)_delegate;
+ (id <GiveIPDelegate>)delegate;
+ (NSArray *)giveTimesArray;

- (void)extendGive:(NSInteger)date;
- (void)saveToObject:(PFObject *)object to:(id)to WithBlock:(void(^) (NSError *))block;
- (void)cancelWithBlock:(void(^) (NSError *))block;

@end
