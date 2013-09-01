//
//  LoginViewController.h
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"
#import "ObjectIP.h"

@interface LoginViewController : UIViewController <UserIPDelegate, ObjectIPLoginDelegate>
{
    @private
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *entrarButton;
}

@end
