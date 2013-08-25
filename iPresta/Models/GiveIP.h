//
//  GiveIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendIP, ObjectIP;

@interface GiveIP : NSManagedObject

@property (nonatomic, retain) NSString * giveId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dateBegin;
@property (nonatomic, retain) NSDate * dateEnd;
@property (nonatomic, retain) ObjectIP *objectIP;
@property (nonatomic, retain) FriendIP *friend;

@end
