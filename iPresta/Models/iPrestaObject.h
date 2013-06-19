//
//  Object.h
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class User;
@class Give;

@protocol iPrestaObjectDelegate <NSObject>

@optional

- (void)getDataResponseWithError:(NSError *)error;
- (void)getSearchResultsResponse:(NSArray *)searchResults withError:(NSError *)error;

@end

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

@interface iPrestaObject : PFObject<PFSubclassing>

@property(retain) User *owner;
@property(assign) ObjectState state;
@property(assign) ObjectType type;
@property(retain) NSString *descriptionObject;
@property(retain) NSString *name;
@property(retain) NSString *author;
@property(retain) NSString *editorial;
@property(retain) NSString *barcode;
@property(retain) PFFile *image;
@property(assign) AudioObjectType audioType;
@property(assign) VideoObjectType videoType;
@property(strong, nonatomic) NSData *imageData;
@property(strong, nonatomic) NSString *imageURL;
@property(strong, nonatomic) id<iPrestaObjectDelegate> delegate;
@property(strong, nonatomic) Give *actualGive;

+ (NSString *)parseClassName;
+ (NSArray *)objectTypes;
+ (NSArray *)audioObjectTypes;
+ (NSArray *)videoObjectTypes;
+ (void)setTypeSelected:(ObjectType)objectType;
+ (ObjectType)typeSelected;
+ (void)setCurrentObject:(iPrestaObject *)object;
+ (iPrestaObject *)currentObject;
+ (NSString *)imageType;

- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset;
- (void)getData:(NSString *)objectCode;
- (BOOL)isEqualToObject:(iPrestaObject *)object;
- (NSString *)textState;
- (NSString *)textType;
- (NSString *)textAudioType;
- (NSString *)textVideoType;

@end
