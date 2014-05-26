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

static id<GiveIPDelegate> delegate;

@dynamic objectId;
@dynamic name;
@dynamic dateBegin;
@dynamic dateEnd;
@dynamic object;
@dynamic to;
@dynamic from;
@dynamic actual;
@dynamic iPrestaObjectId;

+ (void)saveAllGivesFromDBWithBlock:(void (^)(NSError *))block
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
    PFQuery *givesQuery = [PFQuery queryWithClassName:@"Give" predicate:predicate];
    givesQuery.limit = 1000;
    
    [givesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        for (PFObject *give in objects)
        {
            GiveIP *newGive = [GiveIP new];
            [newGive setGiveFrom:give];
            [GiveIP addObject:newGive];
        }
        [GiveIP save];
        block(error);
    }];
}

+ (void)addGivesFromDB
{
    NSArray *allGives = [GiveIP getAll];
    
    NSMutableArray *objectsIdArray = [[NSMutableArray alloc] initWithCapacity:allGives.count];
    
    for (GiveIP *give in allGives) [objectsIdArray addObject:give.objectId];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
    PFQuery *givesQuery = [PFQuery queryWithClassName:@"Give" predicate:predicate];
    [givesQuery whereKey:@"objectId" notContainedIn:objectsIdArray];
    givesQuery.limit = 1000;
    
    [givesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *give in objects) {
                 GiveIP *newGive = [GiveIP new];
                 [newGive setGiveFrom:give];
                 [GiveIP addObject:newGive];
             }
             
             [GiveIP save];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFriendsGivesTableObserver" object:nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewGivesObserver" object:nil];
         }
     }];
}

+ (void)deleteAllGivesFromDBObject:(PFObject *)dbObject andObject:(ObjectIP *)object withBlock:(void (^)(NSError *))block
{
    NSInteger countAllGives = [[object getAllGives] count];
    if (countAllGives == 0) block(nil);
    
    PFQuery *getObjectsQuery = [PFQuery queryWithClassName:@"Give"];
    [getObjectsQuery whereKey:@"object" equalTo:dbObject];
    getObjectsQuery.limit = 1000;
    
    [getObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *gives, NSError *error)
    {
        if (!error)                                      // Si se encuentran los pretamos del objeto, se eliminan
        {
             __block NSInteger count = 0;
             for (PFObject *give in gives)
             {
                 [give deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (!error)
                     {
                         GiveIP *giveIP = [GiveIP getByDBObjectId:give.objectId];
                         [giveIP delete];
                         
                         count++;
                         if (count == countAllGives)
                         {
                             [GiveIP save];
                             block(nil);
                         }
                     }
                     else block(error);
                 }];
             }
         }
         else block(error);     // Si hay error al buscar los prestamos del objeto
     }];
}

- (void)cancelWithBlock:(void(^) (NSError *))block
{
    PFQuery *giveObjectUserQuery = [PFQuery queryWithClassName:@"Give"];
    [giveObjectUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [giveObjectUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error)
         {
             PFObject *give = [objects objectAtIndex:0];
             [give setObject:@NO forKey:@"actual"];
             [give setObject:[NSDate date] forKey:@"dataEnd"];
             
             [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.actual = @NO;
                      self.dateEnd = give[@"dataEnd"];
                      [GiveIP save];
                      
                      block(nil);
                  }
                  else block(error);
              }];
         }
         else block(error);
     }];
}

- (void)saveToObject:(PFObject *)object to:(id)to WithBlock:(void(^) (NSError *))block
{
    PFObject *give = [PFObject objectWithClassName:@"Give"];
    [give setObject:object forKey:@"object"];
    [give setObject:[UserIP loggedUser] forKey:@"from"];
    
    if (self.to) [give setObject:to forKey:@"to"];
    else [give setObject:self.name forKey:@"name"];
    
    [give setObject:self.dateBegin forKey:@"dateBegin"];
    [give setObject:self.dateEnd forKey:@"dateEnd"];
    [give setObject:@YES forKey:@"actual"];
    
    [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            self.objectId = give.objectId;
            [GiveIP save];
            block(nil);
        }
        else block(error);
    }];
}

+ (NSArray *)getAll
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    
    NSError *error;
    return [[[self class] managedObjectContext] executeFetchRequest:request error:&error];
}

+ (void)setDelegate:(id <GiveIPDelegate>)_delegate
{
    delegate = _delegate;
}

+ (id <GiveIPDelegate>)delegate
{
    return delegate;
}

- (void)extendGive:(NSInteger)date
{
    PFQuery *giveObjectUserQuery = [PFQuery queryWithClassName:@"Give"];
    [giveObjectUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [giveObjectUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error)
         {
             PFObject *give = [objects objectAtIndex:0];
             
             NSDate *dateEnd = [[NSDate date] dateByAddingTimeInterval:date];
             [give setObject:dateEnd forKey:@"dataEnd"];
             
             [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.dateEnd = dateEnd;
                      [GiveIP save];
                      
                      if ([delegate respondsToSelector:@selector(extendGiveSuccess)]) [delegate extendGiveSuccess];
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(giveError:)]) [delegate giveError:error];
                  }
              }];
         }
         else
         {
              if ([delegate respondsToSelector:@selector(giveError:)]) [delegate giveError:error];
         }
     }];
}

- (void)setGiveFrom:(PFObject *)give
{
    self.objectId = give.objectId;
    
    if (![[give[@"from"] objectId] isEqual:[UserIP userId]])
    {
        self.from = [FriendIP getByObjectId:[give[@"from"] objectId]];
        self.iPrestaObjectId = [give[@"object"] objectId];
    }
    else
    {
        self.object = [ObjectIP getByObjectId:[give[@"object"] objectId]];
        if (give[@"to"]) self.to = [FriendIP getWithObjectId:[give[@"to"] objectId]];
        else self.name = give[@"name"];
    }
    
    self.dateBegin = give[@"dateBegin"];
    self.dateEnd = give[@"dateEnd"];
    self.actual = give[@"actual"];
}

+ (GiveIP *)getByDBObjectId:(NSString *)dbGiveId
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"giveId = %@", dbGiveId]];
    
    id result = [[self class] executeRequest:request];
    
    if ([result count] > 0) return [result objectAtIndex:0];
    return nil;
}

+ (NSArray *)getMines
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateBegin" ascending:NO]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"from = NULL AND actual = YES"]];
    
    return [[self class] executeRequest:request];
}

+ (NSArray *)getFriends
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateBegin" ascending:NO]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"from != NULL AND actual = YES"]];
    
    return [[self class] executeRequest:request];
}

+ (NSArray *)getMinesInTime
{
    NSArray *mines = [GiveIP getMines];
    NSMutableArray *minesExpired = [NSMutableArray new];
    
    for (GiveIP *give in mines) {
        if (![give isExpired]) [minesExpired addObject:give];
    }
    
    return [minesExpired copy];
}

+ (NSArray *)getFriendsInTime
{
    NSArray *friends = [GiveIP getFriends];
    NSMutableArray *friendsExpired = [NSMutableArray new];
    
    for (GiveIP *give in friends) {
        if (![give isExpired]) [friendsExpired addObject:give];
    }
    
    return [friendsExpired copy];
}

+ (NSArray *)getMinesExpired
{
    NSArray *mines = [GiveIP getMines];
    NSMutableArray *minesExpired = [NSMutableArray new];
    
    for (GiveIP *give in mines) {
        if ([give isExpired]) [minesExpired addObject:give];
    }
    
    return [minesExpired copy];
}

+ (NSArray *)getFriendsExpired
{
    NSArray *friends = [GiveIP getFriends];
    NSMutableArray *friendsExpired = [NSMutableArray new];
    
    for (GiveIP *give in friends) {
        if ([give isExpired]) [friendsExpired addObject:give];
    }
    
    return [friendsExpired copy];
}

+ (NSArray *)getFriendsActuals
{
    NSArray *friends = [GiveIP getFriends];
    NSMutableArray *friendsActuals = [NSMutableArray new];
    
    for (GiveIP *give in friends) {
        if ([give.actual boolValue]) [friendsActuals addObject:give];
    }
    
    return [friendsActuals copy];
}

+ (void)refreshActuals
{
    NSArray *givesFirendsActuals = [GiveIP getFriendsActuals];
    int givesFirendsActualsCount = givesFirendsActuals.count;
    NSMutableArray *objectsIdArray = [[NSMutableArray alloc] initWithCapacity:givesFirendsActualsCount];
    
    if (givesFirendsActuals > 0)
    {
        for (GiveIP *give in givesFirendsActuals) [objectsIdArray addObject:give.objectId];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"from = %@ OR to = %@", [UserIP loggedUser], [UserIP loggedUser]];
        PFQuery *demandsQuery = [PFQuery queryWithClassName:@"Give" predicate:predicate];
        [demandsQuery whereKey:@"objectId" containedIn:objectsIdArray];
        [demandsQuery orderByAscending:@"dateBegin"];
        demandsQuery.limit = 1000;
        
        [demandsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 for (int i = 0; i < givesFirendsActualsCount; i++)
                 {
                     [[givesFirendsActuals objectAtIndex:i] setActual:objects[i][@"actual"]];
                 }
                 
                 [GiveIP save];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadExtendsGivesTableObserver" object:nil];
             }
         }];
    }
}

- (BOOL)isExpired
{
    return ([self.dateEnd compare:[NSDate date]] == NSOrderedAscending);
}

- (void)sendGivePushResponseWithBlock:(void (^)(NSError *))block
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:self.to.objectId];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error)
     {
         PFQuery *pushQuery = [PFInstallation query];
         [pushQuery whereKey:@"user" equalTo:user];
         [pushQuery whereKey:@"isLogged" equalTo:@YES];
         
         PFPush *push = [PFPush new];
         [push setQuery:pushQuery];
         NSString *alert = [NSString stringWithFormat:IPString(@"Prestamo push"), [[UserIP loggedUser] email], self.object.name];
         
         [push setData:[NSDictionary dictionaryWithObjectsAndKeys: @"Increment", @"badge", @"default", @"sound", alert, @"alert", self.objectId, @"demandId", @"give", @"pushID", nil]];
         
         [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
              block(error);
         }];
     }];
}

@end
