//
//  IPCheckbox.m
//  iPresta
//
//  Created by Nacho Brambilla  on 15/05/14.
//  Copyright (c) 2014 Nacho. All rights reserved.
//

#import "IPCheckbox.h"

@implementation IPCheckbox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self addTarget:self action:@selector(checkboxPressed) forControlEvents:UIControlEventTouchDown];
    UIImage *offImage = [UIImage imageNamed:@"cb_mono_off.png"];
    UIImage *onImage = [UIImage imageNamed:@"cb_mono_on.png"];
    
    [self setBackgroundImage:offImage forState:UIControlStateNormal];
    [self setBackgroundImage:onImage forState:UIControlStateSelected];
}

- (void)checkboxPressed
{
    self.selected = !self.selected;
    if ([_delegate respondsToSelector:@selector(checkboxChangeState)]) [_delegate checkboxChangeState];
}

@end
