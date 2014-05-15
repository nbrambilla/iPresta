//
//  SearchObjectCell.h
//  iPresta
//
//  Created by Nacho on 04/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"
#import "FriendIP.h"

@class AsyncImageView;

@interface SearchObjectCell : UITableViewCell
{
    IBOutlet AsyncImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *authorName;
    IBOutlet UILabel *ownerName;
}

- (void)setObject:(ObjectIP *)object withOwner:(PFUser *)owner;

@end
