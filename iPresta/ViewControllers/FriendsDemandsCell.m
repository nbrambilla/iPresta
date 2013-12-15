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
    [dateFormat setDateFormat:NSLocalizedString(@"Formato fecha", nil)];
    date.text = [dateFormat stringFromDate:demand.date];

    if (demand.accepted == nil) stateLabel.hidden = YES;
    else
    {
        stateLabel.text = ([demand.accepted boolValue]) ? NSLocalizedString(@"aceptado", nil) : NSLocalizedString(@"rechazado", nil);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (demand.accepted == nil)
    {
        [acceptButton setTitle:[NSLocalizedString(@"aceptar", nil) uppercaseString] forState:UIControlStateNormal];
        [rejectButton setTitle:[NSLocalizedString(@"rechazar", nil) uppercaseString] forState:UIControlStateNormal];
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
