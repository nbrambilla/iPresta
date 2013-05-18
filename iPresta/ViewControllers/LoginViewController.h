//
//  LoginViewController.h
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    @private
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *entrarButton;
}

@end
