//
//  FriendIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "CoreDataManager_CoreDataManagerExtension.h"

@class GiveIP;
@class DemandIP;

@interface FriendIP : CoreDataManager

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) GiveIP *gives;

+ (NSInteger)newFriends;
+ (void)addFriendsFromDB;
+ (void)getAllFriends:(void (^)(NSError *))block;
+ (void)saveAllFriendsFromDBwithBlock:(void (^)(NSError *))block;
+ (FriendIP *)getWithObjectId:(NSString *)objectId;
+ (FriendIP *)getWithEmail:(NSString *)email;
+ (void)getFromDB:(NSString *)objectId withBlock:(void (^)(NSError *, PFObject *))block;
- (NSString *)firstLetter;
- (NSString *)getFullName;
- (NSString *)getCompareName;

@end

@interface FriendIP (CoreDataGeneratedAccessors)

- (void)addGivesObject:(DemandIP *)value;
- (void)removeGivesObject:(DemandIP *)value;
- (void)addGives:(NSSet *)values;
- (void)removeGives:(NSSet *)values;

- (void)addDemandsMadeObject:(DemandIP *)value;
- (void)removeDemandsMadeObject:(DemandIP *)value;
- (void)addDemandsMade:(NSSet *)values;
- (void)removeDemandsMade:(NSSet *)values;

- (void)addDemandsReciveObject:(DemandIP *)value;
- (void)removeDemandsReciveObject:(DemandIP *)value;
- (void)addDemandsRecive:(NSSet *)values;
- (void)removeDemandsRecive:(NSSet *)values;

@end

@interface FriendIP (CoreDataManager_CoreDataManagerExtension)

+ (FriendIP *)getByObjectId:(NSString *)objectId;

@end
