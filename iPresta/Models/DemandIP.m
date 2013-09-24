//
//  DemandIP.m
//  iPresta
//
//  Created by Nacho on 24/09/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "UserIP.h"
#import "DemandIP.h"
#import "FriendIP.h"
#import "ObjectIP.h"


@implementation DemandIP

@dynamic date;
@dynamic friend;
@dynamic object;
@dynamic objectId;


- (void)saveWithObject:(PFObject *)object withBlock:(void(^) (NSError *))block
{
    PFObject *demand = [PFObject objectWithClassName:@"Demand"];
    [demand setObject:object forKey:@"object"];
    [demand setObject:[object objectForKey:@"owner"] forKey:@"friend"];
    [demand setObject:self.date forKey:@"date"];
    
    [demand saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         if (!error)
         {
             self.objectId = demand.objectId;
             [DemandIP save];
             block(nil);
         }
         else block(error);
     }];
}
@end
