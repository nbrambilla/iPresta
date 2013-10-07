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
@class DemandIP;

@interface FriendIP : CoreDataManager

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) GiveIP *gives;

+ (void)getPermissions:(void (^)(BOOL))block;
+ (void)saveAllFriendsFromDBwithBlock:(void (^)(NSError *))block;
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
