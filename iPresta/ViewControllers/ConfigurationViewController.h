//
//  ConfigurationViewController.h
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "UserIP.h"

@interface ConfigurationViewController : SlideViewController <UserIPDelegate>
{
    @private
    
    IBOutlet UILabel *visibleLabel;
    IBOutlet UILabel *facebookLabel;
    
    IBOutlet UISwitch *visibleSwitch;
    IBOutlet UISwitch *facebookSwitch;
    
    IBOutlet UIView *facebookView;
    IBOutlet UIImageView *profileImage;
    IBOutlet UILabel *nameLabel;
    
    IBOutlet UIButton *logoutButton;
}

@end
