//
//  RequestPasswordResetViewController.h
//  iPresta
//
//  Created by Nacho on 28/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"

@class IPButton;

@interface RequestPasswordResetViewController : UIViewController <UserIPDelegate>
{
    @private
    IBOutlet UITextField *emailTextField;
    IBOutlet IPButton *recoverPasswordButton;
}

@end
