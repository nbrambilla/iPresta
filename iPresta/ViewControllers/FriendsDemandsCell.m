//
//  FriendsDemandsCell.m
//  iPresta
//
//  Created by Nacho on 24/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FriendsDemandsCell.h"
#import "DemandIP.h"
#import "FriendIP.h"
#import "ObjectIP.h"
#import "Language.h"

@implementation FriendsDemandsCell

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDemand:(DemandIP *)newDemand
{
    demand = newDemand;
    
    objectName.text = demand.object.name;
    friendName.text = [demand.from getFullName];
    
    objectImageView.image = (demand.object.image) ? [UIImage imageWithData:demand.object.image] : [UIImage imageNamed:[ObjectIP imageType:[demand.object.type integerValue]]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
    date.text = [dateFormat stringFromDate:demand.date];

    if (demand.accepted == nil) stateLabel.hidden = YES;
    else
    {
        stateLabel.text = ([demand.accepted boolValue]) ? [Language get:@"aceptado" alter:nil] : [Language get:@"rechazado" alter:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (demand.accepted == nil)
    {
        [acceptButton setTitle:[[Language get:@"aceptar" alter:nil] uppercaseString] forState:UIControlStateNormal];
        [rejectButton setTitle:[[Language get:@"rechazar" alter:nil] uppercaseString] forState:UIControlStateNormal];
    }
    else
    {
        acceptButton.hidden = YES;
        rejectButton.hidden = YES;
    }
}

- (IBAction)acceptButtonPressed
{
    if ([_delegate respondsToSelector:@selector(acceptDemand:)]) [_delegate acceptDemand:demand];
}

- (IBAction)rejectButtonPressed
{
    if ([_delegate respondsToSelector:@selector(rejectDemand:)]) [_delegate rejectDemand:demand];
}

@end
