//
//  Give.m
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Give.h"
#import <Parse/PFObject+Subclass.h>

@implementation Give

@dynamic object;
@dynamic dataBegin;
@dynamic dataEnd;
@dynamic name;
@dynamic actual;

+ (NSString *)parseClassName
{
    return @"Give";
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
