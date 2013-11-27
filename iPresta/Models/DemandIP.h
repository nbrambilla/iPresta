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
@property (nonatomic, retain) NSNumber *accepted;
@property (nonatomic, retain) FriendIP *from;
@property (nonatomic, retain) FriendIP *to;
@property (nonatomic, retain) ObjectIP *object;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *iPrestaObjectId;

+ (NSInteger)newDemands;
+ (void)saveAllDemandsFromDBWithBlock:(void (^)(NSError *))block;
+ (void)incrementNewDemands;
+ (void)refreshStates;
+ (void)addDemandsFromDB;
+ (NSArray *)getWithoutState;
+ (NSArray *)getMines;
+ (NSArray *)getFriends;
+ (void)setState:(NSNumber *)accepted toDemandWithId:(NSString *)demandId;

- (void)acceptWithBlock:(void (^)(NSError *))block;
- (void)rejectWithBlock:(void (^)(NSError *))block;
- (void)saveDemandToWithObject:(PFObject *)object withBlock:(void(^) (NSError *, NSString *))block;

@end

@interface DemandIP (CoreDataManager_CoreDataManagerExtension)

+ (DemandIP *)getByObjectId:(NSString *)objectId;

@end
