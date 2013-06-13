//
//  User.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "User.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@implementation User

@dynamic objectId;
@dynamic email;
@dynamic username;
@dynamic password;
@synthesize objectsArray = _objectsArray;

#pragma mark - Class Methods

+ (User *)currentUser
{
    return (User *)[PFUser currentUser];
}

+ (BOOL)currentUserHasEmailVerified
{
    return [[[User currentUser] objectForKey:@"emailVerified"] boolValue];
}

#pragma mark - Class Setters

- (void)setObjectsArray:(NSMutableArray *)objectsArray
{
    _objectsArray = objectsArray;
}

#pragma mark - Class Getters

- (NSMutableArray *)objectsArray
{
    return _objectsArray;
}

# pragma mark - Public Methods

- (BOOL)hasObject:(iPrestaObject *)object
{
    NSInteger sectionIndex = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(firstLetter)];
    
    for (iPrestaObject *personalObject in [self.objectsArray objectAtIndex:sectionIndex])
    {
        if ([object isEqualToObject:personalObject])
        {
            return YES;
        }
    }
    return NO;
}

@end
