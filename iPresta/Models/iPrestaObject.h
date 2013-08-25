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

typedef NS_ENUM(NSUInteger, ObjectStatee) {
    Propertye = 0,
    Givene = 1,
    Receivede = 2,
};

typedef NS_ENUM(NSInteger, ObjectTypee) {
    NoneTypee = -1,
    BookTypee = 0,
    AudioTypee = 1,
    VideoTypee = 2,
    OtherTypee = 3,
};

typedef NS_ENUM(NSInteger, AudioObjectTypee)
{
    NoneAudioObjectTypee = -1,
    CDAudioObjectTypee = 0,
    SACDAudioObjectTypee = 1,
    VinylAudioObjectTypee = 2,
};

typedef NS_ENUM(NSInteger, VideoObjectTypee) {
    NoneVideoObjectTypee = -1,
    DVDVideoObjectTypee = 0,
    BluRayVideoObjectTypee = 1,
    VHSVideoObjectTypee = 2,
};

@interface iPrestaObject : PFObject<PFSubclassing>

@property(retain) User *owner;
@property(assign) ObjectStatee state;
@property(assign) ObjectTypee type;
@property(retain) NSString *descriptionObject;
@property(retain) NSString *name;
@property(retain) NSString *author;
@property(retain) NSString *editorial;
@property(retain) NSString *barcode;
@property(retain) PFFile *image;
@property(assign) AudioObjectTypee audioType;
@property(assign) VideoObjectTypee videoType;
@property(assign) BOOL visible;
@property(strong, nonatomic) NSData *imageData;
@property(strong, nonatomic) NSString *imageURL;
@property(strong, nonatomic) id<iPrestaObjectDelegate> delegate;
@property(strong, nonatomic) Give *actualGive;

+ (NSString *)parseClassName;
+ (NSArray *)objectTypes;
+ (NSArray *)audioObjectTypes;
+ (NSArray *)videoObjectTypes;
+ (void)setTypeSelected:(ObjectTypee)objectType;
+ (ObjectTypee)typeSelected;
+ (void)setCurrentObject:(iPrestaObject *)object;
+ (iPrestaObject *)currentObject;
+ (NSString *)imageType;
+ (NSString *)imageType:(ObjectTypee)objectType;

- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset;
- (void)getData:(NSString *)objectCode;
- (BOOL)isEqualToObject:(iPrestaObject *)object;
- (NSString *)textState;
- (NSString *)textType;
- (NSString *)textAudioType;
- (NSString *)textVideoType;
- (NSString *)getCompareName;

@end
