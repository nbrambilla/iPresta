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
static ObjectIP *currentObject;

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
                                 if (!error)
                                 {
                                     count++;
                                     if (count == objectsCount)
                                     {
                                         [CoreDataManager save];
                                         [loginDelegate saveAllObjectsFromDBresult:nil];
                                     }                                     
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

+ (void)setCurrentObject:(ObjectIP *)_currentObject
{
    currentObject = _currentObject;
}

+ (ObjectIP *)currentObject
{
    return currentObject;
}


#pragma mark -  Array Types Methods

- (NSString *)textState
{
    return [[ObjectIP stateTypes] objectAtIndex:[self.state integerValue]];
}

- (NSString *)textType
{
    return [[ObjectIP objectTypes] objectAtIndex:[self.type integerValue]];
}

- (NSString *)textAudioType
{
    return [[ObjectIP audioObjectTypes] objectAtIndex:[self.audioType integerValue]];
}

- (NSString *)textVideoType
{
    return [[ObjectIP videoObjectTypes] objectAtIndex:[self.videoType integerValue]];
}

+ (NSString *)imageType
{
    return [[ObjectIP imageTypes] objectAtIndex:selectedType];
}

+ (NSString *)imageType:(ObjectType)objectType
{
    return [[ObjectIP imageTypes] objectAtIndex:objectType];
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
                if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
            }
        }];
    }
    
    return nil;
}

- (void)setVisibility:(BOOL)visible
{
    PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectsUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [objectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error)
         {
             PFObject *object = [objects objectAtIndex:0];
             [object setObject:[NSNumber numberWithBool:visible] forKey:@"visible"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      self.visible = [NSNumber numberWithInteger:visible];
                      [ObjectIP save];
                      if ([delegate respondsToSelector:@selector(setVisibilitySuccess)]) [delegate setVisibilitySuccess];
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
                  }
              }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
         }
    }];
}

- (void)giveObjectTo:(NSString *)name from:(NSDate *)dateBegin to:(NSDate *)dateEnd
{
    PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectsUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [objectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             PFObject *object = [objects objectAtIndex:0];
             [object setObject:[NSNumber numberWithInteger:Given] forKey:@"state"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.state = [NSNumber numberWithInteger:Given];
                      [ObjectIP save];
                      
                      GiveIP *newGive = [GiveIP new];
                      newGive.name = name;
                      newGive.dateBegin = dateBegin;
                      newGive.dateEnd = dateEnd;
                      newGive.objectIP = self;
                      newGive.actual = [NSNumber numberWithBool:YES];
                      
                      [newGive saveToObject:object WithBlock:^(NSError *error)
                      {
                          if (!error)
                          {
                              if ([delegate respondsToSelector:@selector(giveObjectSuccess:)]) [delegate giveObjectSuccess:newGive];
                          }
                          else
                          {
                              if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
                          }
                      }];
                      
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
                  }
              }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
         }
     }];
}

- (void)giveBack
{
    PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectsUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [objectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error)
         {
             PFObject *object = [objects objectAtIndex:0];
             [object setObject:[NSNumber numberWithInteger:Property] forKey:@"state"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.state = Property;
                      [ObjectIP save];
                      
                      GiveIP *objectCurrentGive = [self currentGive];
                      
                      [objectCurrentGive cancelWithBlock:^(NSError *error)
                      {
                          if (!error)
                          {
                              if ([delegate respondsToSelector:@selector(giveBackSuccess)]) [delegate giveBackSuccess];
                          }
                          else
                          {
                              if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
                          }

                      }];
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
                  }
              }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
         }
     }];
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
                    if ([delegate respondsToSelector:@selector(error:)]) [delegate objectError:error];
             }
         }];
    }
    
    return nil;
}

- (GiveIP *)currentGive
{
    NSFetchRequest *request = [GiveIP fetchRequest];
    [request setEntity:[GiveIP entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectIP = %@ AND actual = 1", self]];
    
    NSArray *giveObject = [GiveIP executeRequest:request];
    
    if ([giveObject count] > 0) return [giveObject objectAtIndex:0];
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

#pragma mark - Constants Methods

+ (NSArray *)stateTypes
{
    return [NSArray arrayWithObjects:@"No prestado", @"Prestado", @"A devolver", nil];
}

+ (NSArray *)objectTypes
{
    return [NSArray arrayWithObjects:@"Libro", @"Audio", @"Video", @"Otro", nil];
}

+ (NSArray *)audioObjectTypes
{
    return [NSArray arrayWithObjects:@"CD", @"SACD", @"Vinilo", nil];
}

+ (NSArray *)videoObjectTypes
{
    return [NSArray arrayWithObjects:@"DVD", @"Bluray", @"VHS", nil];
}

+ (NSArray *)imageTypes
{
    return [NSArray arrayWithObjects:@"book_icon.png", @"audio_icon.png", @"video_icon.png", @"other_icon.png", nil];
}

@end
