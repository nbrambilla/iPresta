//
//  MyGiveCell.m
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "MyGiveCell.h"
#import "ObjectIP.h"
#import "FriendIP.h"

@implementation MyGiveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setGive:(GiveIP *)give
{
    objectName.text = give.object.name;
    friendName.text = (give.to) ? [give.to getFullName] : give.name;
    
    objectImageView.image = (give.object.image) ? [UIImage imageWithData:give.object.image] : [UIImage imageNamed:[ObjectIP imageType:[give.object.type integerValue]]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:NSLocalizedString(@"Formato fecha", nil)];
    date.text = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"Desde", nil), [dateFormat stringFromDate:give.dateBegin], NSLocalizedString(@"Hasta", nil), [dateFormat stringFromDate:give.dateEnd]];
    
    if ([give isExpired]) stateLabel.text = NSLocalizedString(@"Vencido", nil);
    else stateLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
