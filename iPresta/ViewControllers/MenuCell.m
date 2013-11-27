//
//  MenuCell.m
//  iPresta
//
//  Created by Nacho on 23/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

@synthesize badgeCell = _badgeCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        _badgeCell = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 30, self.frame.size.height)];
        
        _badgeCell.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:_badgeCell];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
        
    // Configure the view for the selected state
}

@end
