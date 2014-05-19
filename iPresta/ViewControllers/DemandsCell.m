//
//  DemandsCell.m
//  iPresta
//
//  Created by Nacho on 15/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "DemandsCell.h"

#define OFFSET 4

@implementation DemandsCell

@synthesize title = _title;
@synthesize myDemandsBadge = _myDemandsBadge;
@synthesize friendsDemandsBadge = _friendsDemandsBadge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 75, self.frame.size.height)];
        _title.numberOfLines = 2;
        _title.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:_title];
        
        UILabel *mines =[[UILabel alloc] initWithFrame:CGRectMake(155, OFFSET, 50, self.frame.size.height/2)];
        mines.text = IPString(@"Mios:");
        mines.font = [UIFont systemFontOfSize:10.0];
        mines.textAlignment = NSTextAlignmentRight;
        mines.backgroundColor = [UIColor clearColor];
        [self addSubview:mines];
        
        _myDemandsBadge = [[UILabel alloc] initWithFrame:CGRectMake(210, OFFSET, 20, self.frame.size.height/2)];
        _myDemandsBadge.font = [UIFont boldSystemFontOfSize:10.0];
        _myDemandsBadge.textAlignment = NSTextAlignmentLeft;
        _myDemandsBadge.backgroundColor = [UIColor clearColor];
        [self addSubview:_myDemandsBadge];
        
        UILabel *friends =[[UILabel alloc] initWithFrame:CGRectMake(155, self.frame.size.height/2 - OFFSET, 50, self.frame.size.height/2)];
        friends.text = IPString(@"Amigos:");
        friends.font = [UIFont systemFontOfSize:10.0];
        friends.textAlignment = NSTextAlignmentRight;
        friends.backgroundColor = [UIColor clearColor];
        [self addSubview:friends];
        
        _friendsDemandsBadge = [[UILabel alloc] initWithFrame:CGRectMake(210, self.frame.size.height/2 - OFFSET, 20, self.frame.size.height/2)];
        _friendsDemandsBadge.font = [UIFont boldSystemFontOfSize:10.0];
        _friendsDemandsBadge.textAlignment = NSTextAlignmentLeft;
        _friendsDemandsBadge.backgroundColor = [UIColor clearColor];
        [self addSubview:_friendsDemandsBadge];
    }
    return self;
}

- (void)setMines:(NSInteger)mines
{
    if (mines > 0)
    {
        _myDemandsBadge.text = [NSString stringWithFormat:@"%d", mines];
    }
    else
    {
        _myDemandsBadge.text = @"-";
    }
}

- (void)setFriends:(NSInteger)friends
{
    if (friends > 0)
    {
        _friendsDemandsBadge.text = [NSString stringWithFormat:@"%d", friends];
    }
    else
    {
        _friendsDemandsBadge.text = @"-";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
