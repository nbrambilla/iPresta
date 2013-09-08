//
//  CoreDataManager.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CoreDataManager_CoreDataManagerExtension.h"
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

+ (NSPersistentStore *)persistentStore
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate persistentStore];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate persistentStoreCoordinator];
}

- (void)delete
{
    [[[self class] managedObjectContext] deleteObject:self];
}

+ (CoreDataManager *)getByObjectId:(NSString *)objectId
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectId = %@", objectId]];
    
    id result = [[self class] executeRequest:request];
    
    if ([result count] > 0) return [result objectAtIndex:0];
    return nil;
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

+ (void)deleteAll
{
    NSArray *allObjects = [[self class] getAll];
    
    for (CoreDataManager *object in allObjects) [object delete];
    
    [[self class] save];
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

+ (id)executeRequest:(NSFetchRequest *)request
{
    NSError *error;
    return [[[self class] managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSInteger)countRequest:(NSFetchRequest *)request
{
    NSError *error;
    return [[[self class] managedObjectContext] countForFetchRequest:request error:&error];
}

+ (void)removePersistentStore
{
    NSError *error;
    [[self managedObjectContext] lock];
    [[self managedObjectContext] reset] ;
    if ([[[self managedObjectContext] persistentStoreCoordinator] removePersistentStore:[[[[self managedObjectContext] persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSURL *storeURL = [NSURL fileURLWithPath: [documentPath stringByAppendingPathComponent: @"iPresta.sqlite"]];
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[[self managedObjectContext] persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [[self managedObjectContext] unlock];
}

@end
