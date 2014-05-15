//
//  AuthenticateEmailViewController.h
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"

@class IPButton;

@interface AuthenticateEmailViewController : UIViewController <UserIPDelegate>
{
    IBOutlet UILabel *authenticateMessage;
    IBOutlet IPButton *resendEmailButton;
    IBOutlet IPButton *goToAppButton;
}

@end
