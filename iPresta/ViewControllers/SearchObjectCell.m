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
    authorName.text = (object.author) ? object.author : NSLocalizedString(@"Desconocido", nil);
    ownerName.text = (owner) ? [[FriendIP getByObjectId:owner.objectId] getFullName] : @"";
    
    objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[object.type integerValue]]];
    if (object.image) objectImageView.image = [UIImage imageWithData:object.image];
    
    else if (object.imageURL && object.image == nil)
    {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:objectImageView];
        objectImageView.imageURL = [NSURL URLWithString:object.imageURL];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end