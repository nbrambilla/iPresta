//
//  AuthenticateEmailViewController.h
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AuthenticateEmailViewController : UIViewController <UserDelegate>

- (void)checkEmailAuthenticationSuccess;
- (void)resendAuthenticateMessageSuccess; 

@end
