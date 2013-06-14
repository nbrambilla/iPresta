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
@dynamic dateBegin;
@dynamic dateEnd;
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

+ (NSArray *)giveTimesArray
{
    return [NSArray arrayWithObjects:@"1 Semana", @"2 Semanas", @"3 Semanas", @"1 Mes", @"2 Meses", @"3 Meses", nil];
}

@end
