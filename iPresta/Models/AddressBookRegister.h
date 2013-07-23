//
//  AddressBookRegister.h
//  iPresta
//
//  Created by Nacho Brambilla on 23/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface AddressBookRegister : NSObject

@property(nonatomic, strong) User *user;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *middleName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *email;

- (id)initWithFirstName:(NSString *)firstName middleName:(NSString *)middleName lastName:(NSString *)lastName andEmail:(NSString *)email;
- (NSString *)firstLetter;
- (NSString *)getFullName;
- (NSString *)getCompareName;

@end
