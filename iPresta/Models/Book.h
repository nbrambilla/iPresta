//
//  Book.h
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Object.h"

@interface Book : Object

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *editorial;
@property(strong, nonatomic) NSString *isbn;

@end
