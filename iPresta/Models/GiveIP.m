//
//  GiveIP.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "GiveIP.h"
#import "FriendIP.h"
#import "ObjectIP.h"


@implementation GiveIP

@dynamic giveId;
@dynamic name;
@dynamic dateBegin;
@dynamic dateEnd;
@dynamic objectIP;
@dynamic friend;


+ (void)saveAllGivesFromDBObject:(PFObject *)object withBlock:(void (^)(NSError *))block
{
    PFQuery *givesQuery = [PFQuery queryWithClassName:@"Give"];
    [givesQuery whereKey:@"object" equalTo:object];
    givesQuery.limit = 1000;
    
    [givesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        for (PFObject *give in objects) {
            GiveIP *newGive = [GiveIP new];
            [newGive setGiveFrom:give];
            [GiveIP addObject:newGive];
        }

        block(error);
    }];
}
- (void)setGiveFrom:(PFObject *)give
{
    self.giveId = give.objectId;
    self.name = [give objectForKey:@"name"];
    self.dateBegin = [give objectForKey:@"dateBegin"];
    self.dateEnd = [give objectForKey:@"dateEnd"];
    self.objectIP = [ObjectIP getByObjectId:[[give objectForKey:@"object"] objectId]];
    self.friend = nil;
}

@end
