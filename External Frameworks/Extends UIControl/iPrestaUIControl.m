//
//  iPrestaUIControl.m
//  iPresta
//
//  Created by Nacho on 09/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaUIControl.h"

@implementation iPrestaUIControl

- (IBAction)hideKeyboard:(id)sender
{
    for (UIView *subview in [sender subviews])
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            if ([subview isFirstResponder]) [subview resignFirstResponder];
        }
    }
}

@end
