//
//  CoreDataManager_CoreDataManagerExtension.h
//  iPresta
//
//  Created by Nacho on 01/09/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager (CoreDataManager_CoreDataManagerExtension)

- (void)delete;

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSEntityDescription *)entityDescription;
+ (NSFetchRequest *)fetchRequest;
+ (id)executeRequest:(NSFetchRequest *)request;
+ (NSInteger)countRequest:(NSFetchRequest *)request;

+ (CoreDataManager *)getByObjectId:(NSString *)objectId;
+ (void)addObject:(NSManagedObject *)object;
+ (NSArray *)getAll;
+ (void)deleteAll;
+ (void)save;

@end
