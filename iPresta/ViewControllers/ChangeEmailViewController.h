//
//  ChangeEmailViewController.h
//  iPresta
//
//  Created by Nacho on 27/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ChangeEmailViewController : UIViewController <UserDelegate>
{
    __weak IBOutlet UILabel *changeMailTextLabel;
    __weak IBOutlet UITextField *emailTextField;
}

@end
