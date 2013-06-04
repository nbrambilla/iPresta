//
//  Give.h
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class iPrestaObject;

@interface Give : PFObject<PFSubclassing>

@property(retain) iPrestaObject *object;
@property(retain) NSDate *dateBegin;
@property(retain) NSDate *dateEnd;
@property(retain) NSString *name;
@property(assign) BOOL actual;

+ (NSString *)parseClassName;

@end
