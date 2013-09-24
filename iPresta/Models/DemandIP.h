//
//  DemandIP.h
//  iPresta
//
//  Created by Nacho on 24/09/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@class FriendIP, ObjectIP;

@interface DemandIP : CoreDataManager

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) FriendIP *friend;
@property (nonatomic, retain) ObjectIP *object;
@property (nonatomic, retain) NSString *objectId;

- (void)saveWithObject:(PFObject *)object withBlock:(void(^) (NSError *))block;

@end
