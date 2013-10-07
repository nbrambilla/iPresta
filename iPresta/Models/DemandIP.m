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
@dynamic from;
@dynamic to;
@dynamic object;
@dynamic objectId;
@dynamic iPrestaObjectId;

+ (void)saveAllDemandsFromDBWithBlock:(void (^)(NSError *))block
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
    PFQuery *demandsQuery = [PFQuery queryWithClassName:@"Demand" predicate:predicate];
    demandsQuery.limit = 1000;
    
    [demandsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         for (PFObject *demand in objects) {
             DemandIP *newDemand = [DemandIP new];
             [newDemand setDemandFrom:demand];
             [DemandIP addObject:newDemand];
         }
         
         block(error);
    }];
}

- (void)saveDemandToWithObject:(PFObject *)object withBlock:(void(^) (NSError *))block
{
    PFObject *demand = [PFObject objectWithClassName:@"Demand"];
    [demand setObject:object forKey:@"object"];
    [demand setObject:[UserIP loggedUser] forKey:@"from"];
    [demand setObject:[object objectForKey:@"owner"] forKey:@"to"];
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

- (void)setDemandFrom:(PFObject *)demand
{
    self.objectId = demand.objectId;
    self.date = [demand objectForKey:@"date"];
    
    if (![[[demand objectForKey:@"from"] objectId] isEqual:[UserIP userId]])
    {
        self.from = [FriendIP getByObjectId:[[demand objectForKey:@"from"] objectId]];
        self.object = [ObjectIP getByObjectId:[[demand objectForKey:@"object"] objectId]];
    }
    else if (![[[demand objectForKey:@"to"] objectId] isEqual:[UserIP userId]])
    {
        self.to = [FriendIP getByObjectId:[[demand objectForKey:@"to"] objectId]];
        self.iPrestaObjectId = [[demand objectForKey:@"object"] objectId];
    }
        
}

+ (NSArray *)getMines
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"from = NULL"]];
    
    return [[self class] executeRequest:request];    
}

+ (NSArray *)getFriends
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"to = NULL"]];
    
    return [[self class] executeRequest:request];
}

@end
