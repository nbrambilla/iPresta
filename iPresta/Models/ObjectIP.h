//
//  ObjectIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager_CoreDataManagerExtension.h"
#import "UserIP.h"

@class GiveIP;
@class UserIP;
@class FriendIP;
@class DemandIP;


typedef NS_ENUM(NSUInteger, ObjectState) {
    Property = 0,
    Given = 1,
    Received = 2,
};

typedef NS_ENUM(NSInteger, ObjectType) {
    NoneType = -1,
    BookType = 0,
    AudioType = 1,
    VideoType = 2,
    OtherType = 3,
};

typedef NS_ENUM(NSInteger, AudioObjectType)
{
    NoneAudioObjectType = -1,
    CDAudioObjectType = 0,
    SACDAudioObjectType = 1,
    VinylAudioObjectType = 2,
};

typedef NS_ENUM(NSInteger, VideoObjectType) {
    NoneVideoObjectType = -1,
    DVDVideoObjectType = 0,
    BluRayVideoObjectType = 1,
    VHSVideoObjectType = 2,
};

@protocol ObjectIPDelegate <NSObject>

@optional

- (void)objectError:(NSError *)error;

- (void)getAllByTypeSuccess:(NSArray *)array;
- (void)countAllByTypeSuccess:(NSArray *)error;
- (void)setVisibilitySuccess;
- (void)giveBackSuccess;
- (void)giveObjectSuccess:(GiveIP *)give;
- (void)demandToSuccess;
- (void)addObjectSuccess;
- (void)deleteObjectSuccess:(id)object;
- (void)getSearchResultsResponse:(NSArray *)searchResults withError:(NSError *)error;
- (void)getDataResponseWithError:(NSError *)error;

- (void)saveAllFromDBresult:(NSError *)error;
- (void)performObjectsSearchSuccess:(NSDictionary *)params error:(NSError *)error;

@end

@protocol ObjectIPLoginDelegate <NSObject>

- (void)saveAllObjectsFromDBresult:(NSError *)error;

@end


@interface ObjectIP : CoreDataManager

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * descriptionObject;
@property (nonatomic, retain) NSString * editorial;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * audioType;
@property (nonatomic, retain) NSNumber * videoType;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSSet *gives;
@property (nonatomic, retain) NSString *imageURL;

+ (void)saveAllObjectsFromDB;
+ (void)setSelectedType:(ObjectType)objectType;
+ (void)setDelegate:(id <ObjectIPDelegate>)_delegate;
+ (id <ObjectIPDelegate>)delegate;
+ (ObjectType)selectedType;
+ (NSArray *)getAllByType;
+ (NSArray *)countAllByType;
+ (void)setLoginDelegate:(id <ObjectIPLoginDelegate>)_loginDelegate;
+ (id <ObjectIPLoginDelegate>)loginDelegate;
+ (void)setCurrentObject:(ObjectIP *)_currentObject;
+ (ObjectIP *)currentObject;
+ (NSString *)imageType;
+ (NSString *)imageType:(ObjectType)objectType;
+ (void)performObjectsSearchWithEmails:(NSArray *)emailsArray param:(NSString *)param page:(NSInteger)_page andOffset:(NSInteger)offset;
+ (void)getDBObjectWithObjectId:(NSString *)objectId withBlock:(void (^)(NSError *, ObjectIP *))block;

- (NSString *)textType;
- (NSString *)textAudioType;
- (NSString *)textVideoType;

- (void)addObjectWithImageData:(NSData *)imageData;
- (void)deleteObject;
- (GiveIP *)currentGive;
- (void)setVisibility:(BOOL)visible;
- (void)demandTo:(PFUser *)friend;
- (void)demandFrom:(FriendIP *)friend withId:(NSString *)demandId;
- (void)giveObjectTo:(id)to from:(NSDate *)dateBegin to:(NSDate *)dateEnd fromDemand:(DemandIP *)demand;
- (void)giveBack;
- (NSArray *)getAllGives;
- (void)getData:(NSString *)objectCode;
- (BOOL)isEqualToObject:(ObjectIP *)object;
- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset;

@end

@interface ObjectIP (CoreDataManager_CoreDataManagerExtension)

+ (ObjectIP *)getByObjectId:(NSString *)objectId;

@end

@interface ObjectIP (CoreDataGeneratedAccessors)

- (NSArray *)getGives;
- (void)addGivesObject:(GiveIP *)value;
- (void)removeGivesObject:(GiveIP *)value;
- (void)addGives:(NSSet *)values;
- (void)removeGives:(NSSet *)values;

- (void)addDemandsObject:(DemandIP *)value;
- (void)removeDemandsObject:(DemandIP *)value;
- (void)addDemands:(NSSet *)values;
- (void)removeDemands:(NSSet *)values;

@end
