//
//  IPTextField.m
//  iPresta
//
//  Created by Nacho Brambilla  on 15/05/14.
//  Copyright (c) 2014 Nacho. All rights reserved.
//

#import "IPTextField.h"

@implementation IPTextField

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
    [self setBorderStyle:UITextBorderStyleNone];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    [self setLeftView:spacerView];
}


@end
