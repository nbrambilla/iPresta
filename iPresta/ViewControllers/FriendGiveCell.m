//
//  FriendGiveCell.m
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FriendGiveCell.h"

@implementation FriendGiveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setGive:(GiveIP *)give withObjectName:(NSString *)name
{
    objectName.text = name;
    friendName.text = [give.from getFullName];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:IPString(@"Formato fecha")];
    date.text = [NSString stringWithFormat:@"%@ %@ %@ %@", IPString(@"Desde"), [dateFormat stringFromDate:give.dateBegin], IPString(@"Hasta"), [dateFormat stringFromDate:give.dateEnd]];

    if ([give isExpired]) stateLabel.text = IPString(@"Vencido");
    else stateLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
