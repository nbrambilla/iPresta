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

@end
