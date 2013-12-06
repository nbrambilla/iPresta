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
@dynamic objectIP;
@dynamic friend;
@dynamic actual;

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
             [give setObject:[NSNumber numberWithBool:NO] forKey:@"actual"];
             [give setObject:[NSDate date] forKey:@"dataEnd"];
             
             [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.actual = [NSNumber numberWithBool:NO];
                      self.dateEnd = [give  objectForKey:@"dataEnd"];
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
    
    if (self.friend) [give setObject:to forKey:@"to"];
    else [give setObject:self.name forKey:@"name"];
    
    [give setObject:self.dateBegin forKey:@"dateBegin"];
    [give setObject:self.dateEnd forKey:@"dateEnd"];
    [give setObject:[NSNumber numberWithBool:YES] forKey:@"actual"];
    
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

+ (NSArray *)giveTimesArray
{
    return [NSArray arrayWithObjects:NSLocalizedString(@"1 Semana", nil), NSLocalizedString(@"2 Semanas", nil), NSLocalizedString(@"3 Semanas", nil), NSLocalizedString(@"1 Mes", nil), NSLocalizedString(@"2 Meses", nil), NSLocalizedString(@"3 Meses", nil), nil];
}

- (void)setGiveFrom:(PFObject *)give
{
    self.objectId = give.objectId;
    
    if ([give objectForKey:@"to"]) self.friend = [FriendIP getWithObjectId:[[give objectForKey:@"to"] objectId]];
    else self.name = [give objectForKey:@"name"];
    
    self.dateBegin = [give objectForKey:@"dateBegin"];
    self.dateEnd = [give objectForKey:@"dateEnd"];
    self.objectIP = [ObjectIP getByObjectId:[[give objectForKey:@"object"] objectId]];
    self.actual = [give objectForKey:@"actual"];
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

@end
