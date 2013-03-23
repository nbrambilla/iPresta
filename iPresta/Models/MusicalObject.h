//
//  Cd.h
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Object.h"

enum {
    CD = 1,
    SACD = 2,
    Vinyl = 3,
};
typedef NSUInteger MusicalObjectType;

@interface MusicalObject : Object

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *artist;
@property(nonatomic) MusicalObjectType type;

@end
