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

@protocol iPrestaObjectDelegate <NSObject>

@optional
- (void)addToCurrentUserSuccess;
- (void)getObjectDataSuccess;
- (void)getObjectsFromUserSuccess:(NSArray *)result;

@end

typedef NS_ENUM(NSUInteger, ObjectState) {
    Property = 0,
    Given = 1,
    Received = 2,
};

typedef NS_ENUM(NSUInteger, ObjectType) {
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

@property(strong, nonatomic) id<iPrestaObjectDelegate> delegate;
@property(retain) PFUser *owner;
@property ObjectState state;
@property ObjectType type;
@property(retain) NSString *description;
@property(retain) NSString *name;
@property(retain) NSString *author;
@property(retain) NSString *editorial;
@property AudioObjectType audioType;
@property VideoObjectType videoType;

+ (NSString *)parseClassName;
+ (NSArray *)objectTypes;
+ (NSArray *)audioObjectTypes;
+ (NSArray *)videoObjectTypes;
+ (void)setDelegate:(id<iPrestaObjectDelegate>)userDelegate;
+ (id<iPrestaObjectDelegate>)delegate;
+ (void)getObjectsFromUser:(User *)user;

- (void)getObjectData:(NSString *)objectCode;
- (void)addToCurrentUser;
- (NSString *)textType;

@end
