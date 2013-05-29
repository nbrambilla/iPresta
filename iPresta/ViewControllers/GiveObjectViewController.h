//
//  GiveObjectViewController.h
//  iPresta
//
//  Created by Nacho on 27/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "STControls.h"

@interface GiveObjectViewController : UIViewController <STDateTextDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    @private
    IBOutlet UITextField *giveToTextField;
    IBOutlet STDateText *fromTextView;
    IBOutlet STDateText *toTextField;
}

@end
