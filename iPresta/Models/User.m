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

static User *objectsUser;

@dynamic objectId;
@dynamic visible;
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

+ (void)setObjectsUser:(User *)user
{
    objectsUser = user;
}

- (void)setObjectsArray:(NSMutableArray *)objectsArray
{
    _objectsArray = objectsArray;
}

#pragma mark - Class Getters

- (NSMutableArray *)objectsArray
{
    return _objectsArray;
}

+ (User *)objectsUser
{
    return (objectsUser) ? objectsUser : [User currentUser];
}

+ (BOOL)objectsUserIsSet
{
    return (![[User objectsUser] isEqual:[User currentUser]]);
}

# pragma mark - Public Methods

- (BOOL)hasObject:(iPrestaObject *)object
{
  //  NSInteger sectionIndex = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(firstLetter)];
    
//    for (iPrestaObject *personalObject in [self.objectsArray objectAtIndex:sectionIndex])
    
    for (NSArray *section in _objectsArray)
    {
        for (iPrestaObject *personalObject in section)
        {
            if ([object isEqualToObject:personalObject])
            {
                return YES;
            }
        }
    }
    return NO;
}

@end
