//
//  ChangeEmailViewController.h
//  iPresta
//
//  Created by Nacho on 27/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"

@interface ChangeEmailViewController : UIViewController <UserIPDelegate>
{
    @private
    IBOutlet UILabel *changeMailTextLabel;
    IBOutlet UITextField *emailTextField;
    IBOutlet UIButton *changeEmailButton;
}

@end
