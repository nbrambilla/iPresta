//
//  ChangeEmailViewController.h
//  iPresta
//
//  Created by Nacho on 27/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"

@class IPTextField;

@interface ChangeEmailViewController : UIViewController <UserIPDelegate>
{
    @private
    IBOutlet UILabel *changeMailTextLabel;
    IBOutlet IPTextField *emailTextField;
    IBOutlet UIButton *changeEmailButton;
}

@end
