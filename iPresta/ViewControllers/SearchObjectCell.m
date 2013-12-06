//
//  SearchObjectCell.m
//  iPresta
//
//  Created by Nacho on 04/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SearchObjectCell.h"

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
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^(void)
                       {
                           object.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:object.imageURL]];
                           
                           UIImage* image = [UIImage imageWithData:object.image];
                           if (image)
                           {
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                      objectImageView.image = image;
                                                      [self setNeedsLayout];
                                        
                                              });
                           }
                       });
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
