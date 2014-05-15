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

@class FriendIP;
@class DemandIP;
@class IPTextField;
@class IPButton;

@interface GiveObjectViewController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, ObjectIPDelegate>
{
    @private
    
    IBOutlet IPTextField *giveToTextField;
    IBOutlet IPTextField *timeTextField;
    
    IBOutlet UIButton *facebookButton;
    IBOutlet IPButton *giveButton;
}

@property(nonatomic, retain) FriendIP *friend;
@property(nonatomic, retain) DemandIP *demand;

@end
