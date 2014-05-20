//
//  MyDemandsCell.m
//  iPresta
//
//  Created by Nacho on 25/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "MyDemandsCell.h"
#import "DemandIP.h"
#import "FriendIP.h"
#import "ObjectIP.h"
#import "AsyncImageView.h"

@implementation MyDemandsCell

@synthesize objectImageView = _objectImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setDemand:(DemandIP *)newDemand withObjectName:(NSString *)name
{
    demand = newDemand;
    
    objectName.text = name;
    friendName.text = [demand.to getFullName];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:IPString(@"Formato fecha")];
    date.text = [dateFormat stringFromDate:demand.date];
    
    if (demand.accepted == nil) stateLabel.text = IPString(@"esperando");
    else
    {
        stateLabel.text = ([demand.accepted boolValue]) ? IPString(@"aceptado") : IPString(@"rechazado");
    }
}

- (void)setObjectImage:(UIImage *)image
{
    _objectImageView.image = image;
}

@end
