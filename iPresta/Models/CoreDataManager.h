//
//  CoreDataManager.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSManagedObject

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
