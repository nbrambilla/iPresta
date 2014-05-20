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
#import "AsyncImageView.h"

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
    
    if (give.object.imageURL)
    {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:objectImageView];
        objectImageView.imageURL = [NSURL URLWithString:give.object.imageURL];
    }
    else objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[give.object.type integerValue]]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:IPString(@"Formato fecha")];
    date.text = [NSString stringWithFormat:@"%@ %@ %@ %@", IPString(@"Desde"), [dateFormat stringFromDate:give.dateBegin], IPString(@"Hasta"), [dateFormat stringFromDate:give.dateEnd]];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
