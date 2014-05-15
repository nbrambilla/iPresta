//
//  ObjectCell.h
//  iPresta
//
//  Created by Nacho on 01/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"

@class AsyncImageView;

@interface ObjectCell : UITableViewCell
{
    IBOutlet AsyncImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *objectAuthor;
}

- (void)setObject:(ObjectIP *)object;

@end
