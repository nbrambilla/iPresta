//
//  FriendGiveCell.m
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FriendGiveCell.h"
#import "ObjectIP.h"
#import "AsyncImageView.h"

@implementation FriendGiveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setGive:(GiveIP *)give withObject:(ObjectIP *)object
{
    objectName.text = object.name;
    friendName.text = [give.from getFullName];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:IPString(@"Formato fecha")];
    date.text = [NSString stringWithFormat:@"%@ %@ %@ %@", IPString(@"Desde"), [dateFormat stringFromDate:give.dateBegin], IPString(@"Hasta"), [dateFormat stringFromDate:give.dateEnd]];

    self.objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[object.type integerValue]]];
    if (object.imageURL) [object imageInImageView:self.objectImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
