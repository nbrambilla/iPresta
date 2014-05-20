//
//  ObjectCell.m
//  iPresta
//
//  Created by Nacho on 01/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectCell.h"
#import "AsyncImageView.h"

@implementation ObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setObject:(ObjectIP *)object
{
    objectName.text = object.name;
    objectAuthor.text = (object.author) ? object.author : IPString(@"Desconocido");
    if (object.imageURL)
    {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:objectImageView];
        objectImageView.imageURL = [NSURL URLWithString:object.imageURL];
    }
    else objectImageView.image = [UIImage imageNamed:[ObjectIP imageType:[object.type integerValue]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.editing)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
            CGRect frame = objectName.frame;
            frame.size.width = 115.0f;
            objectName.frame = frame;
            
            frame = objectAuthor.frame;
            frame.size.width = 115.0f;
            objectAuthor.frame = frame;
        }
        completion:^(BOOL finished) {
        }];
    }
    else
    {
       [UIView animateWithDuration:0.3
                         animations:^{
            CGRect frame = objectName.frame;
            frame.size.width = 210.0f;
            objectName.frame = frame;
            
            frame = objectAuthor.frame;
            frame.size.width = 210.0f;
            objectAuthor.frame = frame;
        }
        completion:^(BOOL finished) {
        }];
    };
}

@end
