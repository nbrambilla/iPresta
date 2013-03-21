//
//  Book.m
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Book.h"

@implementation Book

@synthesize name = _name;
@synthesize editorial = _editorial;
@synthesize isbn = _isbn;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
