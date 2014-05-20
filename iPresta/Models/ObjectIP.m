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
#import "FriendIP.h"
#import "DemandIP.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
//#import "ConnectionData.h"
#import "AFNetworking.h"

@implementation ObjectIP

static id <ObjectIPDelegate> delegate;
static id <ObjectIPLoginDelegate> loginDelegate;
static ObjectType selectedType;
static ObjectIP *currentObject;

@dynamic objectId;
@dynamic name;
@dynamic author;
@dynamic barcode;
@dynamic descriptionObject;
@dynamic editorial;
@dynamic type;
@dynamic audioType;
@dynamic videoType;
@dynamic state;
@dynamic visible;
@dynamic gives;
@dynamic imageURL;


+ (void)saveAllObjectsFromDB
{
    [FriendIP getAllFriends:^(NSError *error)
    {
        if (!error)
        {
            PFQuery *objectsQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
            [objectsQuery whereKey:@"owner" equalTo:[UserIP loggedUser]];
            [objectsQuery orderByAscending:@"image"];
            objectsQuery.limit = 1000;
            [objectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (!error)
                {
                    if (objects.count == 0)  [loginDelegate saveAllObjectsFromDBresult:nil];
            
                    else
                    {                        
                        for (PFObject *object in objects)
                        {
                            ObjectIP *newObject = [ObjectIP new];
                            
                            [newObject setObjetctFrom:object andImage:nil];
                            [ObjectIP addObject:newObject];
                            
                            [ObjectIP save];
                            [GiveIP saveAllGivesFromDBWithBlock:^(NSError *error)
                            {
                                 if (!error)
                                 {
                                      [DemandIP saveAllDemandsFromDBWithBlock:^(NSError * error)
                                      {
                                          [loginDelegate saveAllObjectsFromDBresult:nil];
                                      }];
                                  }
                                  else
                                  {
                                      [loginDelegate saveAllObjectsFromDBresult:error];
                                      return;
                                  }
                            }];
                        }
                    }
                }
                else [loginDelegate saveAllObjectsFromDBresult:error];
            }];
        }
        else [loginDelegate saveAllObjectsFromDBresult:error];
    }];
}

- (void)addObjectWithImageData:(NSData *)imageData
{
    if (![UserIP hasObject:self] )
    {
        PFObject *object = [PFObject objectWithClassName:@"iPrestaObject"];
        
        if ([self.type isEqual:@(BookType)] || [self.type isEqual:@(OtherType)])
        {
            self.audioType = nil;
            self.videoType = nil;
        }
        else if ([self.type isEqual:@(AudioType)]) self.videoType = nil;
        else if ([self.type isEqual:@(VideoType)]) self.audioType = nil;
        
        PFFile *image = nil;
        if (imageData)
        {
            image = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", [OBJECT_TYPES objectAtIndex:[ObjectIP selectedType]]] data:imageData];
        }
        [self setDBObjetct:object withImage:image];

        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)      // Si no hay al guardar el objeto
            {   
                if (!self.managedObjectContext) {
                    ObjectIP *newObject = [ObjectIP new];
                    
                    newObject.objectId = object.objectId;
                    newObject.name = self.name;
                    newObject.author = self.author;
                    newObject.barcode = self.barcode;
                    if (imageData) newObject.imageURL = image.url;
                    newObject.descriptionObject = self.descriptionObject;
                    newObject.editorial = self.editorial;
                    newObject.type = self.type;
                    newObject.audioType = self.audioType;
                    newObject.videoType = self.videoType;
                    newObject.state = self.state;
                    newObject.visible = self.visible;
                }
                [ObjectIP save];
                
                if ([delegate respondsToSelector:@selector(addObjectSuccess)]) [delegate addObjectSuccess];
            }
            else if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
        }];
    }
    else 
    {
        NSError *error = [[NSError alloc] initWithCode:REPEATOBJECT_ERROR userInfo:nil];
        if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
    }
}

- (void)deleteObject
{
    PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectsUserQuery whereKey:@"objectId" equalTo:self.objectId];
    
    [objectsUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error)
         {
            PFObject *object;
            if ([objects count] > 0) object = [objects objectAtIndex:0];
            
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                 if (!error)
                 {
                     [GiveIP deleteAllGivesFromDBObject:object andObject:self withBlock:^(NSError *error)
                     {
                          if (!error)
                          {
                              if ([delegate respondsToSelector:@selector(deleteObjectSuccess:)]) [delegate deleteObjectSuccess:self];
                              [self delete];
                              [ObjectIP save];
                          }
                          else
                          {
                              if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                          }
                      }];
                 }
                 else                                       // Si se elimina el objeto, se actualiza la lista
                 {
                     if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];     // Si hay error al eliminar el objeto
                 }
            }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error]; 
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
    if ([UserIP searchUser] || [UserIP objectsUserIsSet])
    {
        currentObject = [ObjectIP listObjectWithObject:_currentObject];
    }
    else currentObject = _currentObject;
}

+ (ObjectIP *)currentObject
{
    return currentObject;
}


#pragma mark -  Array Types Methods

- (NSString *)textType
{
    return OBJECT_TYPES[self.type.integerValue];
}

- (NSString *)textAudioType
{
    return AUDIO_OBJECT_TYPES[self.audioType.integerValue];
}

- (NSString *)textVideoType
{
    return VIDEO_OBJECTS_TYPE[self.videoType.integerValue];
}

+ (NSString *)imageType
{
    return IMAGE_TYPES[selectedType];
}

+ (NSString *)imageType:(ObjectType)objectType
{
    return IMAGE_TYPES[objectType];
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
        [objectsUserQuery whereKey:@"type" equalTo:@([ObjectIP selectedType])];
        [objectsUserQuery whereKey:@"visible" equalTo:@YES];
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
                    ObjectIP *newObject = [[ObjectIP alloc] initListObject];
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
                if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
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
             [object setObject:@(visible) forKey:@"visible"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      self.visible = @(visible);
                      [ObjectIP save];
                      if ([delegate respondsToSelector:@selector(setVisibilitySuccess)]) [delegate setVisibilitySuccess];
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                  }
              }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
         }
    }];
}

- (void)giveObjectTo:(id)to from:(NSDate *)dateBegin to:(NSDate *)dateEnd fromDemand:(DemandIP *)demand;
{
    if ([to isKindOfClass:[FriendIP class]])
    {
        FriendIP *friend = (FriendIP *)to;
        [FriendIP getFromDB:friend.objectId withBlock:^(NSError *error, PFObject *friend) {
            
            if (!error) [self giveObjectTo:friend from:dateBegin to:dateEnd fromDemand:demand];
            else if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
        }];
    }
    else
    {
        PFQuery *objectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
        [objectsUserQuery whereKey:@"objectId" equalTo:self.objectId];
        
        [objectsUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
        {
             if (!error && object)
             {
                 [object setObject:@(Given) forKey:@"state"];
                 
                 [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                      if (!error)
                      {
                          self.state = @(Given);
                          [ObjectIP save];
                          
                          GiveIP *newGive = [GiveIP new];
                          
                          if ([to isKindOfClass:[PFUser class]]) newGive.to = [FriendIP getWithObjectId:[to objectId]];
                          else newGive.name = to;
                          
                          newGive.dateBegin = dateBegin;
                          newGive.dateEnd = dateEnd;
                          newGive.object = self;
                          newGive.actual = @YES;
                          
                          [newGive saveToObject:object to:to WithBlock:^(NSError *error)
                          {
                              if (!error)
                              {
                                  if (demand)
                                  {
                                      [demand acceptWithBlock:^(NSError *error)
                                      {
                                          if (!error)
                                          {
                                              if ([delegate respondsToSelector:@selector(giveObjectSuccess:)]) [delegate giveObjectSuccess:newGive];
                                          }
                                          else if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                                      }];
                                  }
                                  else if ([newGive.to isKindOfClass:[FriendIP class]]){
                                      [newGive sendGivePushResponseWithBlock:^(NSError *error)
                                      {
                                          if (!error) {
                                              if ([delegate respondsToSelector:@selector(giveObjectSuccess:)]) [delegate giveObjectSuccess:newGive];
                                          }
                                          else if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                                      }];
                                  }
                                  else if ([delegate respondsToSelector:@selector(giveObjectSuccess:)]) [delegate giveObjectSuccess:newGive];
                              }
                              else
                              {
                                  if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                              }
                          }];
                          
                      }
                      else
                      {
                          if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                      }
                  }];
             }
             else
             {
                 if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
             }
         }];
    }
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
             [object setObject:@(Property) forKey:@"state"];
             
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                  if (!error)
                  {
                      self.state = @(Property);
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
                              if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                          }

                      }];
                  }
                  else
                  {
                      if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                  }
              }];
         }
         else
         {
             if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
         }
     }];
}

- (void)demandTo:(PFUser *)user
{
    PFQuery *objectQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectQuery whereKey:@"objectId" equalTo:[[ObjectIP currentObject] objectId]];
    
    [objectQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!error)
        {
            DemandIP *newDemand = [DemandIP new];
            newDemand.to = [FriendIP getWithObjectId:user.objectId];
            newDemand.iPrestaObjectId = self.objectId;
            newDemand.date = [NSDate date];
            
            [newDemand saveDemandToWithObject:object withBlock:^(NSError *error, NSString *demandID)
            {
                if (!error)
                {
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:user];
                    [pushQuery whereKey:@"isLogged" equalTo:@YES];
                    
                    PFPush *push = [PFPush new];
                    [push setQuery:pushQuery];
                    [push setData:[NSDictionary dictionaryWithObjectsAndKeys: @"Increment", @"badge", @"default", @"sound", [NSString stringWithFormat:IPString(@"Push pedido"), [[UserIP loggedUser] username], self.name], @"alert", self.objectId, @"objectId", [[UserIP loggedUser] objectId], @"friendId", demandID, @"demandId", @"demand", @"pushID", nil]];
                    
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                    {
                        if (!error)
                        {
                            if ([delegate respondsToSelector:@selector(demandToSuccess)]) [delegate demandToSuccess];
                        }
                        else
                        {
                            if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                        }
                    }];
                }
                else
                {
                    if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
                }
            }];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
        }
    }];
}

- (void)demandFrom:(FriendIP *)friend withId:(NSString *)demandId
{
    DemandIP *newDemand = [DemandIP new];
    newDemand.objectId = demandId;
    newDemand.from = friend;
    newDemand.object = self;
    newDemand.date = [NSDate date];
    
    [CoreDataManager save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFriendsDemandsTableObserver" object:nil];
}

+ (NSArray *)countAllByType
{
    __block NSMutableArray *objectsTypeArray;
    
    if (![UserIP objectsUserIsSet])
    {
        objectsTypeArray = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (ObjectType type = BookType; type <= OtherType; type++)
        {
            NSFetchRequest *request = [self fetchRequest];
            [request setEntity:[self entityDescription]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"type = %d", type]];
            
            [objectsTypeArray addObject:@([ObjectIP countRequest:request])];
        }
        
        return objectsTypeArray;
    }
    else
    {
        PFQuery *countObjectsUserQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
        [countObjectsUserQuery whereKey:@"owner" equalTo:[UserIP objectsUser]];
        [countObjectsUserQuery whereKey:@"visible" equalTo:@YES];
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
                 
                 objectsTypeArray = [[NSMutableArray alloc] initWithObjects:@(countBooks), @(countAudio), @(countVideo), @(countOthers), nil];
                 
                 if ([delegate respondsToSelector:@selector(countAllByTypeSuccess:)]) [delegate countAllByTypeSuccess:[objectsTypeArray copy]];
             }
             else            // Si hay error al obtener los objetos
             {
                    if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
             }
         }];
    }
    
    return nil;
}

+ (void)getDBObjectWithObjectId:(NSString *)objectId withBlock:(void (^)(NSError *, ObjectIP *))block
{
    PFQuery *objectQuery = [PFQuery queryWithClassName:@"iPrestaObject"];
    [objectQuery whereKey:@"objectId" equalTo:objectId];
    
    [objectQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        ObjectIP *listObject = [[ObjectIP alloc] initListObject];
        if (object[@"image"])
        {
            [object[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
            {
                 if (!error)
                 {
                     [listObject setObjetctFrom:object andImage:data];
                     block(error, listObject);
                 }
            }];
        }
        else
        {
            [listObject setObjetctFrom:object andImage:nil];
            block(error, listObject);
        }
    }];

}
- (GiveIP *)currentGive
{
    NSFetchRequest *request = [GiveIP fetchRequest];
    [request setEntity:[GiveIP entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"object = %@ AND actual = 1", self]];
    
    NSArray *giveObject = [GiveIP executeRequest:request];
    
    if ([giveObject count] > 0) return [giveObject objectAtIndex:0];
    return nil;
}

- (NSArray *)getAllGives
{
    NSArray *givesArray = [[[ObjectIP currentObject] gives] allObjects];
    
    givesArray = [givesArray sortedArrayUsingComparator:^NSComparisonResult(GiveIP *a, GiveIP *b) {
        NSDate *first = a.dateBegin;
        NSDate *second = b.dateBegin;
        return [second compare:first];
    }];
    
    return givesArray;
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
        if ([firstLetter isEqual:@"c"] && [secondLetter isEqual:@"h"]) return @"ch";
        if ([firstLetter isEqual:@"l"] && [secondLetter isEqual:@"l"]) return @"ll";
        return firstLetter;
    }
    
    return self.name;
}

#pragma mark - Get Object Data Methods

- (void)getData:(NSString *)objectCode
{
    objectCode = [objectCode checkCode];
    
    NSString *urlString;
    
    if (selectedType == BookType) urlString = [NSString stringWithFormat:GBOOK_ISBN_URL, objectCode];
    else if (selectedType == AudioType || selectedType == VideoType)
    {
        urlString = [NSString stringWithFormat:DISCOGS_BCODE_URL, objectCode];
        self.barcode = objectCode;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        id volumeInfo;
        NSError *error;
        
        if (selectedType == BookType) volumeInfo = responseObject[@"items"][0][@"volumeInfo"];
        else if (selectedType == AudioType || selectedType == VideoType) volumeInfo = responseObject[@"resp"][@"search"][@"searchresults"][@"results"][0];
        
        if (volumeInfo)
        {
            if (selectedType == BookType) [self setBookWithInfo:volumeInfo];
            else if (selectedType == AudioType || selectedType == VideoType) [self setAudioWithInfo:volumeInfo];
        }
        else
        {
            self.name = nil;
            error = [[NSError alloc] initWithCode:EMPTYOBJECTDATA_ERROR userInfo:nil];
        }
        
        if ([delegate respondsToSelector:@selector(getDataResponseWithError:)]) [delegate getDataResponseWithError:error];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
         NSLog(@"Error: %@", error);
       if ([delegate respondsToSelector:@selector(getDataResponseWithError:)]) [delegate getDataResponseWithError:error];
    }];
}

//- (void)getData:(NSString *)objectCode
//{
//    objectCode = [objectCode checkCode];
//    
//    NSString *urlString;
//    
//    if (selectedType == BookType)
//    {
//        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", objectCode];
//    }
//    else if (selectedType == AudioType || selectedType == VideoType)
//    {
//        urlString = [NSString stringWithFormat:@"http://api.discogs.com/search?q=%@", objectCode];
//        self.barcode = objectCode;
//    }
//    
//    ConnectionData *connection = [[ConnectionData alloc] initWithURL:[NSURL URLWithString:urlString] andID:@"getData"];
//    [connection downloadData:self];
//}

- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset
{
    NSString *urlString;
    
    if (selectedType == BookType) urlString = [NSString stringWithFormat:GBOOKS_SEARCH_URL, param, offset, page*offset];
    else if (selectedType == AudioType) urlString = [NSString stringWithFormat:DISCOGS_SEARCH_URL, param, page, offset];
    else if (selectedType == VideoType) urlString = [NSString stringWithFormat:MOVIEDB_SEARCH_URL, param, page + 1, MOVIES_API_KEY];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableArray *searchResultArray;
         id volumeInfoArray;
         
         if (selectedType == BookType) volumeInfoArray = responseObject[@"items"];
         else if (selectedType == AudioType) volumeInfoArray = responseObject[@"results"];
         else if (selectedType == VideoType) volumeInfoArray = responseObject[@"results"];
         
         if ([volumeInfoArray count] > 0)
         {
             searchResultArray = [[NSMutableArray alloc] initWithCapacity:[volumeInfoArray count]];
             
             for (id volumeInfo in volumeInfoArray)
             {
                 ObjectIP *object = [[ObjectIP alloc] initListObject];
                 object.type = @(selectedType);
                 
                 if (selectedType == BookType)  [object setBookWithInfo:volumeInfo[@"volumeInfo"]];
                 else if (selectedType == AudioType) [object setAudioWithInfo:volumeInfo];
                 else if (selectedType == VideoType) [object setVideoWithInfo:volumeInfo];
                 
                 [searchResultArray addObject:object];
             }
         }
         
         if ([delegate respondsToSelector:@selector(getSearchResultsResponse:withError:)]) [delegate getSearchResultsResponse:[searchResultArray copy] withError:nil];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
        if ([delegate respondsToSelector:@selector(getSearchResultsResponse:withError:)]) [delegate getSearchResultsResponse:nil withError:error];
     }];
}


//- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset
//{
//    NSString *urlString;
//    
//    if (selectedType == BookType) urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=%@&maxResults=%d&startIndex=%d", param, offset, page*offset];
//    else if (selectedType == AudioType) urlString = [NSString stringWithFormat:@"http://api.discogs.com/database/search?title=%@&type=release&page=%d&per_page=%d", param, page, offset];
//    else if (selectedType == VideoType) urlString = [NSString stringWithFormat:@"http://api.themoviedb.org/3/search/movie?query=%@&page=%d&api_key=%@", param, page+1, MOVIES_API_KEY];
//    
//    ConnectionData *connection = [[ConnectionData alloc] initWithURL:[NSURL URLWithString:urlString] andID:@"getSearchResults"];
//    [connection downloadData:self];
//}

//- (void)dataFinishLoading:(ConnectionData *)connection error:(NSError *)error
//{
//    if (!error)      // Si no error hay al buscar el/los objeto/s
//    {
//        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.requestData options:NSJSONReadingMutableContainers error:&error];
//        
//        if ([connection.identifier isEqual:@"getData"])
//        {
//            id volumeInfo;
//            
//            if (selectedType == BookType)
//            {
//                volumeInfo = [[[response objectForKey:@"items"] objectAtIndex:0] objectForKey:@"volumeInfo"];
//            }
//            else if (selectedType == AudioType || selectedType == VideoType)
//            {
//                volumeInfo = [[[[[response objectForKey:@"resp"] objectForKey:@"search"] objectForKey:@"searchresults"] objectForKey:@"results"] objectAtIndex:0];
//            }
//            
//            if (volumeInfo)
//            {
//                if (selectedType == BookType)
//                {
//                    [self setBookWithInfo:volumeInfo];
//                }
//                else if (selectedType == AudioType || selectedType == VideoType)
//                {
//                    [self setAudioWithInfo:volumeInfo];
//                }
//            }
//            else
//            {
//                self.name = nil;
//                error = [[NSError alloc] initWithCode:EMPTYOBJECTDATA_ERROR userInfo:nil];
//            }
//            
//            if ([delegate respondsToSelector:@selector(getDataResponseWithError:)]) [delegate getDataResponseWithError:error];
//        }
//        else if ([connection.identifier isEqual:@"getSearchResults"])
//        {
//            NSMutableArray *searchResultArray;
//            id volumeInfoArray;
//            
//            if (selectedType == BookType)
//            {
//                volumeInfoArray = [response objectForKey:@"items"];
//            }
//            else if (selectedType == AudioType)
//            {
//                volumeInfoArray = [response objectForKey:@"results"];
//            }
//            else if (selectedType == VideoType)
//            {
//                volumeInfoArray = [response objectForKey:@"results"];
//            }
//            
//            if ([volumeInfoArray count] > 0)
//            {
//                searchResultArray = [[NSMutableArray alloc] initWithCapacity:[volumeInfoArray count]];
//                
//                for (id volumeInfo in volumeInfoArray)
//                {
//                    ObjectIP *object = [[ObjectIP alloc] initListObject];
//                    object.type = @(selectedType);
//                    
//                    if (selectedType == BookType)  [object setBookWithInfo:[volumeInfo objectForKey:@"volumeInfo"]];
//                    else if (selectedType == AudioType) [object setAudioWithInfo:volumeInfo];
//                    else if (selectedType == VideoType) [object setVideoWithInfo:volumeInfo];
//                    
//                    [searchResultArray addObject:object];
//                }
//            }
//            
//            
//            if ([delegate respondsToSelector:@selector(getSearchResultsResponse:withError:)])
//            {
//                [delegate getSearchResultsResponse:[searchResultArray copy] withError:error];
//            }
//        }
//    }
//    else
//    {
//        if ([delegate respondsToSelector:@selector(objectError:)]) [delegate objectError:error];
//    }
//}

+ (void)performObjectsSearchWithEmails:(NSArray *)emailsArray param:(NSString *)param page:(NSInteger)_page andOffset:(NSInteger)offset
{
    // se crea una consulta para poder buscar todos los usuarios de la app de que tenemos en la agenda a partir del array de emails.
    PFQuery *appUsersQuery = [PFUser query];
    [appUsersQuery whereKey:@"email" containedIn:emailsArray];
    [appUsersQuery whereKey:@"visible" equalTo:@YES];
    
    // texto con primeras letras de cada palabra en mayuscula
    PFQuery *queryCapitalizedString = [PFQuery queryWithClassName:@"iPrestaObject"];
    [queryCapitalizedString whereKey:@"visible" equalTo:@YES];
    [queryCapitalizedString whereKey:@"owner" matchesQuery:appUsersQuery];
    [queryCapitalizedString whereKey:@"name" containsString:[param capitalizedString]];
    
    // texto en minuscula
    PFQuery *queryLowerCaseString = [PFQuery queryWithClassName:@"iPrestaObject"];
    [queryLowerCaseString whereKey:@"visible" equalTo:@YES];
    [queryLowerCaseString whereKey:@"owner" matchesQuery:appUsersQuery];
    [queryLowerCaseString whereKey:@"name" containsString:[param lowercaseString]];
    
    // texto real
    PFQuery *querySearchBarString = [PFQuery queryWithClassName:@"iPrestaObject"];
    [querySearchBarString whereKey:@"visible" equalTo:@YES];
    [querySearchBarString whereKey:@"owner" matchesQuery:appUsersQuery];
    [querySearchBarString whereKey:@"name" containsString:param];
    
    // Combinacion de consultas para poder comparar el parametro con los nombres de los objetos. Subconsulta para poder encontrar los contactos con cuenta en la app.
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
    [finalQuery orderByAscending:@"name"];
    [finalQuery includeKey:@"owner"];
    [finalQuery orderByAscending:@"image"];
    finalQuery.skip = _page * offset;
    finalQuery.limit = offset;
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *pfObjects, NSError *error)
    {
        __block int objectsCount = [pfObjects count];
        __block int count = 0;
        
        if (objectsCount == 0)
        {
            [delegate performObjectsSearchSuccess:nil error:nil];
            return;
        }
        
        NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:objectsCount];
        NSMutableArray *owners = [[NSMutableArray alloc] initWithCapacity:objectsCount];
        
        for (PFObject *pfObject in pfObjects)
        {
            ObjectIP *object = [[ObjectIP alloc] initListObject];
            if (pfObject[@"image"])
            {
                [pfObject[@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                {
                     if (!error)
                     {
                         [object setObjetctFrom:pfObject andImage:data];
                         [objects addObject:object];
                         [owners addObject:pfObject[@"owner"]];
                         
                         count++;
                         if (count == objectsCount)
                         {
                             if ([delegate respondsToSelector:@selector(performObjectsSearchSuccess:error:)])
                             {
                                 NSDictionary *params = @{@"objects": objects, @"owners": owners};
                                 [delegate performObjectsSearchSuccess:params error:nil];
                             }
                         }
                     }
                     else
                     {
                         if ([delegate respondsToSelector:@selector(performObjectsSearchSuccess:error:)])
                         {
                             [delegate performObjectsSearchSuccess:nil error:error];
                         }
                     }
                }];
            }
            else
            {
                [object setObjetctFrom:pfObject andImage:nil];
                [objects addObject:object];
                [owners addObject:[pfObject objectForKey:@"owner"]];
                
                count++;
                if (count == objectsCount)
                {
                    if ([delegate respondsToSelector:@selector(performObjectsSearchSuccess:error:)])
                    {
                        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:objects, @"objects", owners, @"owners", nil];
                        
                        [delegate performObjectsSearchSuccess:params error:nil];
                    }
                }

            }
        }
    }];
}

#pragma mark - Set Object Methods

- (void)setBookWithInfo:(id)info
{
    // Se setea el nombre del objeto
    if ([info objectForKey:@"title"])
    {
        self.name = [info[@"title"] capitalizedString];
        if (info[@"subtitle"]) self.name = [self.name stringByAppendingFormat:@" %@", [info[@"subtitle"] capitalizedString]];
    }
    // Se setea el autor del objeto
    if (info[@"authors"])
    {
        id authors = info[@"authors"];
        self.author = @"";
        
        for (NSString *author in authors)
        {
            self.author = [self.author stringByAppendingString:[author capitalizedString]];
            
            if (![[authors lastObject] isEqual:author])
            {
                self.author = [self.author stringByAppendingString:@", "];
            }
        }
    }
    // Se setea la editorial del objeto
    if (info[@"publisher"]) self.editorial = [info[@"publisher"] capitalizedString];
    // se setea la imagen
    if (info[@"imageLinks"])
    {
        id images = [info objectForKey:@"imageLinks"];
        
        if (images[@"extraLarge"]) self.imageURL = images[@"extraLarge"];
        else if (images[@"large"]) self.imageURL = images[@"large"];
        else if (images[@"medium"]) self.imageURL = images[@"medium"];
        else if (images[@"small"]) self.imageURL = images[@"small"];
        else if (images[@"thumbnail"]) self.imageURL = images[@"thumbnail"];
        else if (images[@"smallThumbnail"]) self.imageURL = images[@"smallThumbnail"];
        
        images = nil;
    }
    // se setea el isbn
    if (info[@"industryIdentifiers"])
    {
        id barcodes = info[@"industryIdentifiers"];
        
        if ([barcodes count] == 1) self.barcode = barcodes[0][@"identifier"];
        else if ([barcodes count] == 2)
        {
            if ([barcodes[1][@"type"] isEqual:@"ISBN_13"]) self.barcode = barcodes[1][@"identifier"];
            else self.barcode = barcodes[0][@"identifier"];
        }
        else self.barcode = barcodes[1][@"identifier"];
        
        barcodes = nil;
    }
}

- (void)setAudioWithInfo:(id)info
{
    // se setea el titulo y el autor
    if (info[@"title"])
    {
        id title = [info[@"title"] componentsSeparatedByString: @" - "];
        if ([title count] > 1)
        {
            self.author = title[0];
            self.name = title[1];
        }
    }
    // se setea la imagen
    if (info[@"thumb"]) self.imageURL = [info[@"thumb"] stringByReplacingOccurrencesOfString:@"api.discogs.com" withString:@"s.pixogs.com"];
}

- (void)setVideoWithInfo:(id)info
{
    // se setea el titulo
    if (info[@"original_title"] != [NSNull null]) self.name = info[@"original_title"];
    // se setea el director
    if (info[@"directors"] != [NSNull null])
    {
        id directors = info[@"directors"];
        self.author = @"";
        
        for (NSString *director in directors)
        {
            self.author = [self.author stringByAppendingString:director];
            
            if (![[directors lastObject] isEqual:director])
            {
                self.author = [self.author stringByAppendingString:@", "];
            }
        }
    }
    // se setea la imagen
    if (info[@"poster_path"] != [NSNull null])
    {
//        if ([[info objectForKey:@"poster"] objectForKey:@"imdb"] != [NSNull null]) self.imageURL = [[info objectForKey:@"poster"] objectForKey:@"imdb"];
//        else if ([[info objectForKey:@"poster"] objectForKey:@"cover"] != [NSNull null]) self.imageURL = [[info objectForKey:@"poster"] objectForKey:@"cover"];
        self.imageURL = [NSString stringWithFormat:MOVIE_IMAGE_URL, info[@"poster_path"]];
        
    }
    // se setea el identificador
    if (info[@"imdb_id"] != [NSNull null]) self.barcode = info[@"imdb_id"];
}

+ (ObjectIP *)listObjectWithObject:(ObjectIP *)object
{
    ObjectIP *listObject = [[ObjectIP alloc] initListObject];
    listObject.objectId = object.objectId;
    listObject.name = object.name;
    listObject.author = object.author;
    listObject.barcode = object.barcode;
    listObject.descriptionObject = object.descriptionObject;
    listObject.editorial = object.editorial;
    listObject.type = object.type;
    listObject.imageURL = object.imageURL;
    listObject.audioType = object.audioType;
    listObject.videoType = object.videoType;
    listObject.state = object.state;
    listObject.visible = object.visible;
    
    return listObject;
}

- (void)setObjetctFrom:(PFObject *)object andImage:(NSData* )data
{
    self.objectId = object.objectId;
    self.name = object[@"name"];
    self.author = object[@"author"];
    self.barcode = object[@"barcode"];
    self.descriptionObject = object[@"descriptionObject"];
    self.editorial = object[@"editorial"];
    self.type = object[@"type"];
    
    PFFile *file = (PFFile *)object[@"image"];
    self.imageURL = file.url;

    self.audioType = object[@"audioType"];
    self.videoType = object[@"videoType"];
    self.state = object[@"state"];
    self.visible = [NSNumber numberWithBool:object[@"visible"]];
}

- (void)setDBObjetct:(PFObject *)object withImage:(PFFile* )data
{
    [object setObject:[UserIP loggedUser] forKey:@"owner"];
    [object setObject:self.name forKey:@"name"];
    if (self.author) [object setObject:self.author forKey:@"author"];
    if (self.barcode) [object setObject:self.name forKey:@"barcode"];
    if (data) [object setObject:data forKey:@"image"];
    if (self.descriptionObject) [object setObject:self.descriptionObject forKey:@"descriptionObject"];
    if (self.editorial) [object setObject:self.editorial forKey:@"editorial"];
    [object setObject:self.type forKey:@"type"];
    if (self.audioType) [object setObject:self.audioType forKey:@"audioType"];
    if (self.videoType) [object setObject:self.videoType forKey:@"videoType"];
    [object setObject:self.state forKey:@"state"];
    [object setObject:@([self.visible boolValue]) forKey:@"visible"];
}

- (BOOL)isEqualToObject:(ObjectIP *)object
{
    if (self.barcode && [self.barcode isEqualToString:object.barcode]) return YES;
    
    NSString *firstChain = (self.author) ? [[self.name stringByAppendingString:self.author] serialize] : [self.name serialize];
    
    NSString *secondChain = (object.author) ? [[object.name stringByAppendingString:object.author] serialize] : [object.name serialize];
    
    NSInteger distance = [firstChain distance:secondChain];
    NSInteger coef = (int)([firstChain length] * 0.1 + 0.5);
    
    if (distance <= coef) return YES;
    //if ([[self.name serialize] isEqual:[object.name serialize]] && [[self.author serialize] isEqualToString:[object.author serialize]]) return YES;
    return  NO;
    
    firstChain = nil;
    secondChain = nil;
    distance = nil;
    coef = nil;
}

@end
