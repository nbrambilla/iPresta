//
//  Object.m
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaObject.h"

@implementation iPrestaObject

@synthesize id = _id;
@synthesize state = _state;
@synthesize description = _description;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
