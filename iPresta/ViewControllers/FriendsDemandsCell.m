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
#import "AsyncImageView.h"
#import "IPButton.h"

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
    
    objectImageView.image = [UIImage imageNamed:IMAGE_TYPES[demand.object.type.integerValue]];
    if (demand.object.imageURL) objectImageView.imageURL = [NSURL URLWithString:demand.object.imageURL];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:IPString(@"Formato fecha")];
    date.text = [dateFormat stringFromDate:demand.date];
    
    acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
    rejectButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (demand.accepted == nil)
    {
        [acceptButton setTitle:[IPString(@"aceptar") uppercaseString] forState:UIControlStateNormal];
        [rejectButton setTitle:[IPString(@"rechazar") uppercaseString] forState:UIControlStateNormal];
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
