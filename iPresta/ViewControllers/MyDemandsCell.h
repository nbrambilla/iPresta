//
//  MyDemandsCell.h
//  iPresta
//
//  Created by Nacho on 25/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemandIP;

@interface MyDemandsCell : UITableViewCell
{
    DemandIP *demand;
    IBOutlet UILabel *objectName;
    IBOutlet UILabel *friendName;
    IBOutlet UILabel *date;
    IBOutlet UILabel *stateLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView *objectImageView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *imageIndicatorView;

- (void)setDemand:(DemandIP *)newDemand withObjectName:(NSString *)name;

@end
