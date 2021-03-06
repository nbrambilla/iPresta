//
//  MyDemandsCell.h
//  iPresta
//
//  Created by Nacho on 25/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemandIP;
@class AsyncImageView;
@class ObjectIP;

@interface MyDemandsCell : UITableViewCell
{
    DemandIP *demand;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
}

@property(nonatomic, retain) IBOutlet AsyncImageView *objectImageView;

- (void)setDemand:(DemandIP *)newDemand withObject:(ObjectIP *)object;

@end
