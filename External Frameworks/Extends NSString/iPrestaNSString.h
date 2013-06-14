//
//  iPrestaNSString.h
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

@interface NSString (iPrestaNSString)

+ (BOOL)areSetUsername:(NSString *)username andPassword:(NSString *)password;
- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (BOOL)matchWith:(NSString *)confirmPassword;
- (NSString *)formatName;
- (NSString *)formatCode;
- (NSInteger)getIntegerTime;
- (NSString *)encodeToURL;

@end
