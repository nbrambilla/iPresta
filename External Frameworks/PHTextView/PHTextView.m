//
//  PHTextView.m
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "PHTextView.h"

@implementation PHTextView

@synthesize placeholder = _placeholder;

- (id)awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    placeholderLabel = [[UILabel alloc] init];
    
    placeholderLabel.textColor = [UIColor lightGrayColor];
    placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:placeholderLabel];
    
    self.clipsToBounds = YES;
    self.delegate = self;
    
    return self;
}

- (NSString *)placeholder
{
    return _placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    placeholderLabel.text = placeholder;
    [placeholderLabel sizeToFit];
    placeholderLabel.frame = CGRectMake(8.0f, 8.0f, placeholderLabel.frame.size.width, placeholderLabel.frame.size.height);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) placeholderLabel.hidden = YES;
    else placeholderLabel.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length > 0) placeholderLabel.hidden = YES;
    else placeholderLabel.hidden = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
