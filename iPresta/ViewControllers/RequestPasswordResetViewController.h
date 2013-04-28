//
//  RequestPasswordResetViewController.h
//  iPresta
//
//  Created by Nacho on 28/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RequestPasswordResetViewController : UIViewController <UserDelegate>
{
    __weak IBOutlet UITextField *emailTextField;
}

- (void)requestPasswordResetSuccess;

@end
