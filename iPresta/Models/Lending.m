//
//  Lending.m
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Lending.h"

@implementation Lending

@synthesize id = _id;
@synthesize dataBegin = _dataBegin;
@synthesize dataEnd = _dataEnd;
@synthesize name = _name;
@synthesize email = _email;
@synthesize phone = _phone;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
