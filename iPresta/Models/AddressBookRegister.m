//
//  AddressBookRegister.m
//  iPresta
//
//  Created by Nacho Brambilla on 23/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AddressBookRegister.h"

@implementation AddressBookRegister

@synthesize user = _user;
@synthesize firstName = _firstName;
@synthesize middleName = _middleName;
@synthesize lastName = _lastName;
@synthesize email = _email;

#pragma mark - Public Methods

- (id)initWithFirstName:(NSString *)firstName middleName:(NSString *)middleName lastName:(NSString *)lastName andEmail:(NSString *)email
{
    self = [super init];
    if (self)
    {
        _firstName = firstName;
        _middleName = middleName;
        _lastName = lastName;
        _email = email;
    }
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
}

- (void)setFirstName:(NSString *)firstName
{
    _firstName = firstName;
}

- (void)setMiddleName:(NSString *)middleName
{
    _middleName = middleName;
}

- (void)setLastName:(NSString *)lastName
{
    _lastName = lastName;
}

- (void)setEmail:(NSString *)email
{
    _email = email;
}

- (User *)user
{
    return _user;
}

- (NSString *)name
{
    return _firstName;
}

- (NSString *)middleName
{
    return _middleName;
}

- (NSString *)lastName
{
    return _lastName;
}

- (NSString *)email
{
    return _email;
}

- (NSString *)firstLetter
{
    NSString *compareName = [self getCompareName];
    NSInteger len = [compareName length];
    
    if (len > 1)
    {
        NSString *firstLetter = [[compareName substringWithRange:NSMakeRange(0, 1)] lowercaseString];
        NSString *secondLetter = [[compareName substringWithRange:NSMakeRange(1, 1)] lowercaseString];
        if ([firstLetter isEqual:@"c"] && [secondLetter isEqual:@"h"])
        {
            return @"ch";
        }
        if ([firstLetter isEqual:@"l"] && [secondLetter isEqual:@"l"])
        {
            return @"ll";
        }
        return firstLetter;
    }
    
    return compareName;
}

- (NSString *)getFullName
{
    NSString *name;
    if (_firstName) name = _firstName;
    if (_middleName) name = [name stringByAppendingFormat:@" %@", _middleName ];
    if (_lastName) name = [name stringByAppendingFormat:@" %@", _lastName ];
    
    return name;
}

- (NSString *)getCompareName
{
    if (_lastName) return _lastName;
    if (_middleName) return _middleName;
    return _lastName;
}

@end
