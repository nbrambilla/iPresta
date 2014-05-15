//
//  CreateCountViewController.h
//  iPresta
//
//  Created by Nacho on 18/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIP.h"
#import "ObjectIP.h"

@class IPButton;
@class IPTextField;

@interface CreateCountViewController : UIViewController <UserIPDelegate, ObjectIPLoginDelegate>
{
    @private
    IBOutlet IPTextField *emailTextField;
    IBOutlet IPTextField *passwordTextField;
    IBOutlet IPTextField *repeatPasswordTextField;
    IBOutlet IPButton *createCountButton;
    IBOutlet IPButton *createCountFBButton;
}

@end
