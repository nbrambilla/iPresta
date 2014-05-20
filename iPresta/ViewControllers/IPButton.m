//
//  IPButton.m
//  iPresta
//
//  Created by Nacho Brambilla  on 14/05/14.
//  Copyright (c) 2014 Nacho. All rights reserved.
//

#import "IPButton.h"

@implementation IPButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
}

- (void)drawRect:(CGRect)rect
{
    UIImage *normalImage = [[UIImage imageNamed:@"button_off.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *selectedImage = [[UIImage imageNamed:@"button_on.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
    [self setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    
}

@end
