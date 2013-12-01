//
//  ObjectCell.h
//  iPresta
//
//  Created by Nacho on 01/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"

@interface ObjectCell : UITableViewCell
{
    IBOutlet UIImageView *objectImageView;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *objectAuthor;
}

- (void)setObject:(ObjectIP *)object;

@end
