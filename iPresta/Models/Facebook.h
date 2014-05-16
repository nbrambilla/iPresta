//
//  Facebook.h
//  iPresta
//
//  Created by Nacho on 10/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Foundation/Foundation.h>

@interface Facebook : NSObject
{
    @private
    NSString *accessToken;
}

- (void)shareText:(NSString *)text block:(void (^)(NSError *))block;
- (void)login:(void (^)(NSError *))block;
- (void)link:(BOOL)link block:(void (^)(NSError *))block;
//- (void)shareInFacebook:(NSString *)caption;

@end
