//
//  MyGiveCell.h
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiveIP.h"

@class AsyncImageView;

@interface MyGiveCell : UITableViewCell
{
    IBOutlet AsyncImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
}

- (void)setGive:(GiveIP *)give;

@end
