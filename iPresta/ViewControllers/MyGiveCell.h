//
//  MyGiveCell.h
//  iPresta
//
//  Created by Nacho on 09/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiveIP.h"

@interface MyGiveCell : UITableViewCell
{
    IBOutlet UIImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
    IBOutlet UILabel *stateLabel;
}

- (void)setGive:(GiveIP *)give;

@end
