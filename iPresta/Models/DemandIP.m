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

static NSInteger newDemands;

@dynamic date;
@dynamic accepted;
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
        [DemandIP save];
         block(error);
    }];
}

+ (void)refreshStates
{
    NSArray *demandsWithoutState = [DemandIP getWithoutState];
    int demandsWithoutStateCount = demandsWithoutState.count;
    NSMutableArray *objectsIdArray = [[NSMutableArray alloc] initWithCapacity:demandsWithoutStateCount];
    
    if (demandsWithoutStateCount > 0)
    {
        for (DemandIP *demand in demandsWithoutState) [objectsIdArray addObject:demand.objectId];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
        PFQuery *demandsQuery = [PFQuery queryWithClassName:@"Demand" predicate:predicate];
        [demandsQuery whereKey:@"objectId" containedIn:objectsIdArray];
        [demandsQuery orderByAscending:@"objectId"];
        demandsQuery.limit = 1000;
        
        [demandsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
             if (!error)
             {
                 for (int i = 0; i < demandsWithoutStateCount; i++) {
                     [[demandsWithoutState objectAtIndex:i] setAccepted:[[objects objectAtIndex:i] objectForKey:@"accepted"]];
                 }
                 
                 [DemandIP save];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMyDemandsTableObserver" object:nil];
             }
        }];
    }
}

+ (void)addDemandsFromDB
{
    NSArray *allDemands = [DemandIP getAll];
    NSMutableArray *objectsIdArray = [[NSMutableArray alloc] initWithCapacity:allDemands.count];
    
    for (DemandIP *demand in allDemands) [objectsIdArray addObject:demand.objectId];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
    PFQuery *demandsQuery = [PFQuery queryWithClassName:@"Demand" predicate:predicate];
    [demandsQuery whereKey:@"objectId" notContainedIn:objectsIdArray];
    demandsQuery.limit = 1000;
    
    [demandsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            newDemands += objects.count;
            for (PFObject *demand in objects) {
                DemandIP *newDemand = [DemandIP new];
                [newDemand setDemandFrom:demand];
                [DemandIP addObject:newDemand];
            }
            
            [DemandIP save];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFriendsDemandsTableObserver" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
        }
    }];
}

- (void)saveDemandToWithObject:(PFObject *)object withBlock:(void(^) (NSError *, NSString *))block
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
             block(nil, demand.objectId);
         }
         else block(error, nil);
     }];
}

+ (NSArray *)getMines
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"from = NULL AND accepted = NULL"]];
    
    return [[self class] executeRequest:request];
}

+ (NSArray *)getFriends
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"to = NULL AND accepted = NULL"]];
    
    return [[self class] executeRequest:request];
}

+ (NSArray *)getWithoutState
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"accepted = NULL AND from = NULL"]];
    
    return [[self class] executeRequest:request];
}

+ (void)setState:(NSNumber *)accepted toDemandWithId:(NSString *)demandId
{
    DemandIP *demand = [DemandIP getByObjectId:demandId];
    demand.accepted = accepted;
    
    [DemandIP save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMyDemandsTableObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
}

- (void)setDemandFrom:(PFObject *)demand
{
    self.objectId = demand.objectId;
    self.date = [demand objectForKey:@"date"];
    self.accepted = [demand objectForKey:@"accepted"];
    
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

- (void)acceptWithBlock:(void (^)(NSError *))block
{
    PFQuery *demandQuery = [PFQuery queryWithClassName:@"Demand"];
    [demandQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [demandQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (!error && object)
         {
             self.accepted = @YES;
             [object setObject:self.accepted forKey:@"accepted"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error) [DemandIP save];
                 [self sendPushResponse:self.accepted withBlock:^(NSError *error)
                 {
                      block(error);
                 }];
             }];
         }
         else block(error);
     }];
}

- (void)rejectWithBlock:(void (^)(NSError *))block
{
    PFQuery *demandQuery = [PFQuery queryWithClassName:@"Demand"];
    [demandQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [demandQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
         if (!error && object)
         {
             self.accepted = @NO;
             [object setObject:self.accepted forKey:@"accepted"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error) {
                      [DemandIP save];
                      [self sendPushResponse:self.accepted withBlock:^(NSError *error)
                      {
                          block(error);
                      }];
                  }
                  block(error);
              }];
         }
         else block(error);
     }];
}

- (void)sendPushResponse:(NSNumber *)accepted withBlock:(void (^)(NSError *))block
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:self.from.objectId];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error)
    {
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:user];
        [pushQuery whereKey:@"isLogged" equalTo:@YES];
        
        PFPush *push = [PFPush new];
        [push setQuery:pushQuery];
        NSString *alert = [NSString stringWithFormat:NSLocalizedString(@"Respuesta pedido push", nil), self.object.name, [[UserIP loggedUser] email], ([accepted boolValue]) ? [NSLocalizedString(@"aceptado", nil) uppercaseString]: [NSLocalizedString(@"rechazado", nil) uppercaseString]];
        
        [push setData:[NSDictionary dictionaryWithObjectsAndKeys: @"Increment", @"badge", @"default", @"sound", alert, @"alert", self.objectId, @"demandId", @"response", @"pushID", accepted, @"accepted", nil]];
        
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            block(error);
        }];
     }];
}

@end
