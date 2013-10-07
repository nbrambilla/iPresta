//
//  ObjectDetailViewController.h
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"
#import "GiveIP.h"
#import "UserIP.h"

@interface ObjectDetailViewController : UIViewController <ObjectIPDelegate, GiveIPDelegate, UserIPDelegate>
{
    @private
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *typeLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UILabel *editorialLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *stateLabel;
    IBOutlet UILabel *loanUpLabel;
    
    IBOutlet UIView *currentUserButtonsView;
    IBOutlet UIButton *giveButton;
    IBOutlet UIButton *giveBackButton;
    IBOutlet UIButton *loanUpButton;
    IBOutlet UIButton *historycButton;
    IBOutlet UISwitch *visibleSwitch;
    
    IBOutlet UIButton *demandButton;
    
    IBOutlet UIView *otherUserButtonsView;
    
}

@end
