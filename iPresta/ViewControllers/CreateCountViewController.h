//
//  CreateCountViewController.h
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"

@interface CreateCountViewController : UIViewController <UserIPDelegate>
{
    @private
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *repeatPasswordTextField;
}

@end
