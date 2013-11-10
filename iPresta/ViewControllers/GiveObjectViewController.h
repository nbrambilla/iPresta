//
//  GiveObjectViewController.h
//  iPresta
//
//  Created by Nacho on 27/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ObjectIP.h"

@interface GiveObjectViewController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, ObjectIPDelegate>
{
    @private
    IBOutlet UITextField *giveToTextField;
    IBOutlet UITextField *timeTextField;
    
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
}

@end
