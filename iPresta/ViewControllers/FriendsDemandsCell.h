//
//  FriendsDemandsCell.h
//  iPresta
//
//  Created by Nacho on 24/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemandIP;
@class IPButton;
@class AsyncImageView;

@protocol FriendsDemandsCellDelegate <NSObject>

- (void)acceptDemand:(DemandIP *)demand;
- (void)rejectDemand:(DemandIP *)demand;

@end

@interface FriendsDemandsCell : UITableViewCell
{
    DemandIP *demand;
    IBOutlet AsyncImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
    IBOutlet IPButton *acceptButton;
    IBOutlet IPButton *rejectButton;
}

@property(nonatomic, retain) id <FriendsDemandsCellDelegate> delegate;

- (void)setDemand:(DemandIP *)newDemand;

@end
