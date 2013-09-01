//
//  ObjectIP.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/Parse.h>
#import "ObjectIP.h"
#import "GiveIP.h"
#import "UserIP.h"

@implementation ObjectIP

static id <ObjectIPDelegate> delegate;
static id <ObjectIPLoginDelegate> loginDelegate;
static ObjectType selectedType;

@dynamic objectId;
@dynamic name;
@dynamic author;
@dynamic image;
@dynamic barcode;
@dynamic descriptionObject;
@dynamic editorial;
@dynamic type;
@dynamic audioType;
@dynamic videoType;
@dynamic state;
@dynamic visible;
@dynamic gives;


+ (void)saveAllObjectsFromDB
{
    PFQuery *objectsQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectsQuery whereKey:@"owner" equalTo:[UserIP loggedUser]];
    [objectsQuery orderByAscending:@"image"];
    objectsQuery.limit = 1000;
    [objectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            __block int objectsCount = [objects count];
            __block int count = 0;
            
            for (PFObject *object in objects)
            {
                ObjectIP *newObject = [ObjectIP new];
                
                if ([object objectForKey:@"image"])
                {
                    [[object objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                    {
                         if (!error)
                         {
                             [newObject setObjetctFrom:object andImage:data];
                             [ObjectIP addObject:newObject];
                             
                             [GiveIP saveAllGivesFromDBObject:object withBlock:^(NSError *error)
                             {
                                 if (error)
                                 {
                                     [loginDelegate saveAllObjectsFromDBresult:error];
                                     return;
                                 }
                                 else
                                 {
                                     count++;
                                     if (count == objectsCount)
                                     {
                                         [CoreDataManager save];
                                         [loginDelegate saveAllObjectsFromDBresult:nil];
                                     }
                                 }
                             }];
                         }
                         else
                         {
                             [loginDelegate saveAllObjectsFromDBresult:error];
                             return;
                         }
                    }];
                }
                else
                {
                    [newObject setObjetctFrom:object andImage:nil];
                    [ObjectIP addObject:newObject];
                    
                    [GiveIP saveAllGivesFromDBObject:object withBlock:^(NSError *error)
                    {
                         if (error)
                         {
                             [loginDelegate saveAllObjectsFromDBresult:error];
                             return;
                         }
                         else
                         {
                             count++;
                             if (count == objectsCount)
                             {
                                 [CoreDataManager save];
                                 [loginDelegate saveAllObjectsFromDBresult:nil];
                             }
                         }
                     }];
                }
            }
        }
        else
        {
            [loginDelegate saveAllObjectsFromDBresult:error];
        }
    }];
}



+ (ObjectType)selectedType
{
    return selectedType;
}

+ (void)setSelectedType:(ObjectType)objectType
{
    selectedType = objectType;
}

+ (void)setDelegate:(id <ObjectIPDelegate>)_delegate
{
    delegate = _delegate;
}

+ (id <ObjectIPDelegate>)delegate
{
    return delegate;
}

+ (void)setLoginDelegate:(id <ObjectIPLoginDelegate>)_loginDelegate
{
    loginDelegate = _loginDelegate;
}

+ (id <ObjectIPLoginDelegate>)loginDelegate
{
    return loginDelegate;
}

+ (NSArray *)getAllByType
{
    if (![UserIP objectsUserIsSet])
    {
        NSFetchRequest *request = [self fetchRequest];
        [request setEntity:[self entityDescription]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"type = %d", [ObjectIP selectedType]]];
        
        NSMutableArray *objectsArray = [[ObjectIP executeRequest:request] mutableCopy];
        
        return [NSMutableArray arrayWithArray:[self partitionObjects:objectsArray collationStringSelector:@selector(firstLetter)]];
    }
    else
    {
        PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
        [objectsUserQuery whereKey:@"owner" equalTo:[UserIP objectsUser]];
        [objectsUserQuery whereKey:@"type" equalTo: [NSNumber numberWithInt:[ObjectIP selectedType]]];
        [objectsUserQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
        [objectsUserQuery orderByAscending:@"image"];
        objectsUserQuery.limit = 1000;
        [objectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if (!error)
            {
                __block int count = 0;
                __block int objectsCount = [objects count];
                
                NSMutableArray *objectsUserArray = [[NSMutableArray alloc] initWithCapacity:objectsCount];
                
                if (count == objectsCount)
                {
                    if ([delegate respondsToSelector:@selector(getAllByTypeSuccess:)]) [delegate getAllByTypeSuccess:[[self partitionObjects:objectsUserArray collationStringSelector:@selector(firstLetter)] copy]];
                }
                
                for (id object in objects)
                {
                    ObjectIP *newObject = [ObjectIP new];
                    if ([object objectForKey:@"image"])
                    {
                        [[object objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                         {
                             if (!error)
                             {
                                 [newObject setObjetctFrom:object andImage:data];
                                 [objectsUserArray addObject:newObject];
                                 
                                 count++;
                                 if (count == objectsCount)
                                 {
                                     if ([delegate respondsToSelector:@selector(getAllByTypeSuccess:)]) [delegate getAllByTypeSuccess:[[self partitionObjects:objectsUserArray collationStringSelector:@selector(firstLetter)] copy]];
                                 }
                             }
                         }];
                    }
                    else
                    {
                        [newObject setObjetctFrom:object andImage:nil];
                        [objectsUserArray addObject:newObject];
                        
                        count++;
                        if (count == objectsCount)
                        {
                            if ([delegate respondsToSelector:@selector(getAllByTypeSuccess:)]) [delegate getAllByTypeSuccess:[[self partitionObjects:objectsUserArray collationStringSelector:@selector(firstLetter)] copy]];
                        }
                    }
                }
            }
            else
            {
                if ([delegate respondsToSelector:@selector(getAllByTypeError:)]) [delegate getAllByTypeError:error];
            }
        }];
    }
    
    return nil;
}

+ (NSArray *)countAllByType
{
    __block NSMutableArray *objectsTypeArray;
    
    if (![UserIP objectsUserIsSet])
    {
        objectsTypeArray = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (ObjectType type = BookType; type < 4; type++)
        {
            NSFetchRequest *request = [self fetchRequest];
            [request setEntity:[self entityDescription]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"type = %d", type]];
            
            NSInteger objectsCount = [ObjectIP countRequest:request];
            
            [objectsTypeArray addObject:[NSNumber numberWithInt:objectsCount]];
        }
        
        return objectsTypeArray;
    }
    else
    {
        PFQuery *countObjectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
        [countObjectsUserQuery whereKey:@"owner" equalTo:[UserIP objectsUser]];
        [countObjectsUserQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
        countObjectsUserQuery.limit = 1000;
        
        [countObjectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
             if (!error)      // Si se obtienen los objetos, se cuentan cuantos hay de cada tipo
             {
                 int countBooks = 0, countAudio = 0, countVideo = 0, countOthers = 0;
                 for (id object in objects)
                 {
                     switch ([[object objectForKey:@"type"] integerValue]) {
                         case 0:
                             countBooks++;
                             break;
                         case 1:
                             countAudio++;
                             break;
                         case 2:
                             countVideo++;
                             break;
                         case 3:
                             countOthers++;
                             break;
                         default:
                             break;
                     }
                 }
                 
                 objectsTypeArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:countBooks], [NSNumber numberWithInt:countAudio], [NSNumber numberWithInt:countVideo], [NSNumber numberWithInt:countOthers], nil];
                 
                 if ([delegate respondsToSelector:@selector(countAllByTypeSuccess:)]) [delegate countAllByTypeSuccess:[objectsTypeArray copy]];
             }
             else            // Si hay error al obtener los objetos
             {
                    if ([delegate respondsToSelector:@selector(countAllByTypeError:)]) [delegate countAllByTypeError:error];
             }
         }];
    }
    
    return nil;
}

#pragma mark - Private Methods

+ (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (ObjectIP *object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:@selector(getCompareName)] mutableCopy]];
    }
    
    return sections;
}

- (NSString *)getCompareName
{
    return self.name;
}

- (NSString *)firstLetter
{
    NSInteger len = [self.name length];
    
    if (len > 1)
    {
        NSString *firstLetter = [[self.name substringWithRange:NSMakeRange(0, 1)] lowercaseString];
        NSString *secondLetter = [[self.name substringWithRange:NSMakeRange(1, 1)] lowercaseString];
        if ([firstLetter isEqual:@"c"] && [secondLetter isEqual:@"h"])
        {
            return @"ch";
        }
        if ([firstLetter isEqual:@"l"] && [secondLetter isEqual:@"l"])
        {
            return @"ll";
        }
        return firstLetter;
    }
    
    return self.name;
}

- (void)setObjetctFrom:(PFObject *)object andImage:(NSData* )data
{
    self.objectId = object.objectId;
    self.name = [object objectForKey:@"name"];
    self.author = [object objectForKey:@"author"];
    self.barcode = [object objectForKey:@"barcode"];
    self.descriptionObject = [object objectForKey:@"descriptionObject"];
    self.editorial = [object objectForKey:@"editorial"];
    self.type = [object objectForKey:@"type"];
    self.image = [[NSData alloc] initWithData:data];
    self.audioType = [object objectForKey:@"audioType"];
    self.videoType = [object objectForKey:@"videoType"];
    self.state = [object objectForKey:@"state"];
    self.visible = [NSNumber numberWithBool:[object objectForKey:@"visible"]];
}

@end
