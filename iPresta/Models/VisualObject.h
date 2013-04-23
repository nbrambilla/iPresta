//
//  VisualObject.h
//  iPresta
//
//  Created by Nacho on 23/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaObject.h"

enum {
    DVD = 1,
    BluRay = 2,
    VHS = 3,
};
typedef NSUInteger VisualObjectType;

@interface VisualObject : iPrestaObject

@property(strong, nonatomic) NSString *name;
@property(nonatomic) VisualObjectType type;

@end
