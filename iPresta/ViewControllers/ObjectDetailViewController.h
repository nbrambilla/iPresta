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
#import "IPCheckbox.h"

@class IPButton;
@class AsyncImageView;

@interface ObjectDetailViewController : UIViewController <ObjectIPDelegate, GiveIPDelegate, UserIPDelegate, IPCheckboxDelegate>
{
    @private
    IBOutlet AsyncImageView *imageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UILabel *editorialLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *stateLabel;
    IBOutlet UILabel *loanUpLabel;
    IBOutlet UILabel *visibleLabel;
    
    IBOutlet UIView *currentUserButtonsView;
    IBOutlet IPButton *giveButton;
    IBOutlet IPButton *giveBackButton;
    IBOutlet IPButton *loanUpButton;
    IBOutlet IPButton *historycButton;
    IBOutlet IPCheckbox *visibleCheckbox;
    
    IBOutlet IPButton *demandButton;
    
    IBOutlet UIView *otherUserButtonsView;
    
}

@end
