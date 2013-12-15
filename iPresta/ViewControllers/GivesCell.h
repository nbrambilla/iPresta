//
//  GivesCell.h
//  iPresta
//
//  Created by Nacho on 15/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GivesCell : UITableViewCell

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *myGivesBadge;
@property (nonatomic, retain) UILabel *friendsGivesBadge;

- (void)setMines:(NSInteger)mines;
- (void)setFriends:(NSInteger)friends;

@end
