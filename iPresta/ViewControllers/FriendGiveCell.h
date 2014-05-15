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

@interface FriendGiveCell : UITableViewCell
{
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
    IBOutlet UILabel *stateLabel;
}

@property(nonatomic, retain) IBOutlet AsyncImageView *objectImageView;

- (void)setGive:(GiveIP *)newDemand withObjectName:(NSString *)name;

@end
