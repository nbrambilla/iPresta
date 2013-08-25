//
//  CoreDataManager.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CoreDataManager.h"
#import "ObjectIP.h"

@implementation CoreDataManager

- (id)init
{    
    self = [[[self class] alloc] initWithEntity:[[self class] entityDescription] insertIntoManagedObjectContext:[[self class] managedObjectContext]];
    
    return self;
}

+ (void)addObject:(NSManagedObject *)object
{
    [[[self class] managedObjectContext] insertObject:object];
}

+ (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

+ (void)save
{
    NSError *error;
    if (![[[self class] managedObjectContext] save:&error])
    {
        NSLog(@"Error de Core Data %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

+ (NSArray *)getAll
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    
    NSError *error;
    return [[[self class] managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[[self class] managedObjectContext]];
}

+ (NSFetchRequest *)fetchRequest
{
    return [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
}

@end
