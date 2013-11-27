//
//  FriendsDemandsCell.h
//  iPresta
//
//  Created by Nacho on 24/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemandIP;

@protocol FriendsDemandsCellDelegate <NSObject>

- (void)acceptDemand:(DemandIP *)demand;
- (void)rejectDemand:(DemandIP *)demand;

@end

@interface FriendsDemandsCell : UITableViewCell
{
    DemandIP *demand;
    IBOutlet UIImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
    IBOutlet UIButton *acceptButton;
    IBOutlet UIButton *rejectButton;
    IBOutlet UILabel *stateLabel;
    
}

@property(nonatomic, retain) id <FriendsDemandsCellDelegate> delegate;

- (void)setDemand:(DemandIP *)newDemand;

@end
