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
#import "Language.h"

@implementation MyDemandsCell

@synthesize objectImageView = _objectImageView;
@synthesize imageIndicatorView = _imageIndicatorView;

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
    [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
    date.text = [dateFormat stringFromDate:demand.date];
    
    if (demand.accepted == nil) stateLabel.text = [Language get:@"esperando" alter:nil];
    else
    {
        stateLabel.text = ([demand.accepted boolValue]) ? [Language get:@"aceptado" alter:nil] : [Language get:@"rechazado" alter:nil];
    }
}

- (void)setObjectImage:(UIImage *)image
{
    _objectImageView.image = image;
}

@end
