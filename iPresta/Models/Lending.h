//
//  Lending.h
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lending : NSObject

@property(strong, nonatomic) NSString *id;
@property(strong, nonatomic) NSData *dataBegin;
@property(strong, nonatomic) NSData *dataEnd;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *phone;

@end
