//
//  SearchObjectCell.m
//  iPresta
//
//  Created by Nacho on 04/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SearchObjectCell.h"
#import "AsyncImageView.h"

@implementation SearchObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setObject:(ObjectIP *)object withOwner:(PFUser *)owner
{
    objectName.text = [object.name capitalizedString];
    authorName.text = (object.author) ? object.author : IPString(@"Desconocido");
    ownerName.text = (owner) ? [[FriendIP getByObjectId:owner.objectId] getFullName] : @"";
    
    objectImageView.image = [UIImage imageNamed:IMAGE_TYPES[object.type.integerValue]];
    if (object.imageURL) [object imageInImageView:objectImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
