//
//  ObjectIP.h
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager_CoreDataManagerExtension.h"

@class GiveIP;
@class UserIP;

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
- (void)addObjectSuccess;
- (void)deleteObjectSuccess:(id)object;
- (void)getSearchResultsResponse:(NSArray *)searchResults withError:(NSError *)error;
- (void)getDataResponseWithError:(NSError *)error;

- (void)saveAllFromDBresult:(NSError *)error;

@end

@protocol ObjectIPLoginDelegate <NSObject>

- (void)saveAllObjectsFromDBresult:(NSError *)error;

@end


@interface ObjectIP : CoreDataManager

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSData * image;
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

@end

@interface ObjectIP (CoreDataGeneratedAccessors)

+ (ObjectIP *)getByObjectId:(NSString *)objectId;
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
+ (NSArray *)objectTypes;
+ (NSArray *)stateTypes;
+ (NSArray *)audioObjectTypes;
+ (NSArray *)videoObjectTypes;

- (NSString *)textState;
- (NSString *)textType;
- (NSString *)textAudioType;
- (NSString *)textVideoType;

- (void)addObject;
- (void)deleteObject;
- (GiveIP *)currentGive;
- (NSArray *)getGives;
- (void)setVisibility:(BOOL)visible;
- (void)giveObjectTo:(NSString *)name from:(NSDate *)dateBegin to:(NSDate *)dateEnd;
- (void)giveBack;
- (NSArray *)getAllGives;
- (void)getData:(NSString *)objectCode;
- (BOOL)isEqualToObject:(ObjectIP *)object;
- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset;
- (void)addGivesObject:(GiveIP *)value;
- (void)removeGivesObject:(GiveIP *)value;
- (void)addGives:(NSSet *)values;
- (void)removeGives:(NSSet *)values;

@end
