//
//  DemandsCell.h
//  iPresta
//
//  Created by Nacho on 15/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemandsCell : UITableViewCell

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *myDemandsBadge;
@property (nonatomic, retain) UILabel *friendsDemandsBadge;

- (void)setMines:(NSInteger)mines;
- (void)setFriends:(NSInteger)friends;

@end
