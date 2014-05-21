//
//  FriendGiveCell.h
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiveIP.h"
#import "FriendIP.h"

@class AsyncImageView;
@class ObjectIP;

@interface FriendGiveCell : UITableViewCell
{
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
}

@property(nonatomic, retain) IBOutlet AsyncImageView *objectImageView;

- (void)setGive:(GiveIP *)newDemand withObject:(ObjectIP *)object;

@end
