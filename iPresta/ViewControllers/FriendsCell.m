//
//  FriendsCell.m
//  iPresta
//
//  Created by Nacho on 23/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FriendsCell.h"

@implementation FriendsCell

@synthesize badgeCell = _badgeCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        
        UILabel *news =[[UILabel alloc] initWithFrame:CGRectMake(155, 0, 50, self.frame.size.height)];
        news.text = IPString(@"Nuevos:");
        news.font = [UIFont systemFontOfSize:10.0];
        news.textAlignment = NSTextAlignmentRight;
        news.backgroundColor = [UIColor clearColor];
        [self addSubview:news];
        
        _badgeCell = [[UILabel alloc] initWithFrame:CGRectMake(210, 0, 20, self.frame.size.height)];
        _badgeCell.font = [UIFont boldSystemFontOfSize:10.0];
        [self addSubview:_badgeCell];
    }
    return self;
}

- (void)setNews:(NSInteger)news
{
    if (news > 0) _badgeCell.text = [NSString stringWithFormat:@"%d", news];
    else _badgeCell.text = @"-";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
        
    // Configure the view for the selected state
}

@end
