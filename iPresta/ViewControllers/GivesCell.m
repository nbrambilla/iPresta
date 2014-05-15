//
//  GivesCell.m
//  iPresta
//
//  Created by Nacho on 15/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "GivesCell.h"

#define OFFSET 4

@implementation GivesCell

@synthesize title = _title;
@synthesize myGivesBadge = _myGivesBadge;
@synthesize friendsGivesBadge = _friendsGivesBadge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 80, self.frame.size.height)];
        _title.numberOfLines = 2;
        _title.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:_title];
        
        UILabel *mines =[[UILabel alloc] initWithFrame:CGRectMake(155, OFFSET, 50, self.frame.size.height/2)];
        mines.text = NSLocalizedString(@"Mios:", nil);
        mines.font = [UIFont systemFontOfSize:10.0];
        mines.textAlignment = NSTextAlignmentRight;
        mines.backgroundColor = [UIColor clearColor];
        [self addSubview:mines];
        
        _myGivesBadge = [[UILabel alloc] initWithFrame:CGRectMake(210, OFFSET, 20, self.frame.size.height/2)];
        _myGivesBadge.font = [UIFont boldSystemFontOfSize:10.0];
        _myGivesBadge.textAlignment = NSTextAlignmentLeft;
        _myGivesBadge.backgroundColor = [UIColor clearColor];
        [self addSubview:_myGivesBadge];

        UILabel *friends =[[UILabel alloc] initWithFrame:CGRectMake(155, self.frame.size.height/2 - OFFSET, 50, self.frame.size.height/2)];
        friends.text = NSLocalizedString(@"Amigos:", nil);
        friends.font = [UIFont systemFontOfSize:10.0];
        friends.textAlignment = NSTextAlignmentRight;
        friends.backgroundColor = [UIColor clearColor];
        [self addSubview:friends];
        
        _friendsGivesBadge = [[UILabel alloc] initWithFrame:CGRectMake(210, self.frame.size.height/2 - OFFSET, 20, self.frame.size.height/2)];
        _friendsGivesBadge.font = [UIFont boldSystemFontOfSize:10.0];
        _friendsGivesBadge.textAlignment = NSTextAlignmentLeft;
        _friendsGivesBadge.backgroundColor = [UIColor clearColor];
        [self addSubview:_friendsGivesBadge];
    }
    return self;
}

- (void)setMines:(NSInteger)mines
{
    if (mines > 0)
    {
        _myGivesBadge.text = [NSString stringWithFormat:@"%d", mines];
    }
    else
    {
        _myGivesBadge.text = @"-";
    }
}

- (void)setFriends:(NSInteger)friends
{
    if (friends > 0)
    {
        _friendsGivesBadge.text = [NSString stringWithFormat:@"%d", friends];
    }
    else
    {
        _friendsGivesBadge.text = @"-";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
