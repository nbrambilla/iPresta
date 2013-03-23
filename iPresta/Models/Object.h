//
//  Object.h
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    Property = 1,
    Given = 2,
    Received = 3,
};
typedef NSUInteger ObjectState;

@interface Object : NSObject

@property(strong, nonatomic) NSString *id;
@property(strong, nonatomic) NSString *state;
@property(strong, nonatomic) NSString *description;

@end
