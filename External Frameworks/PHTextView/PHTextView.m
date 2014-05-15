//
//  PHTextView.m
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "PHTextView.h"
#import <QuartzCore/QuartzCore.h>

#define GRAY_COLOR_BORDER [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]
#define GRAY_COLOR_TEXT [UIColor colorWithRed:199.0f/255.0f green:199.0f/255.0f blue:205.0f/255.0f alpha:1.0f]

@implementation PHTextView

@synthesize placeholder = _placeholder;

- (id)awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    placeholderLabel = [[UILabel alloc] init];
    
    placeholderLabel.textColor = GRAY_COLOR_TEXT;
    placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:placeholderLabel];
    
    self.contentInset = UIEdgeInsetsMake(2.0, 3.0, -5.0, -5.0);
    self.layer.borderColor = [GRAY_COLOR_BORDER CGColor];
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 7.0f;
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
    placeholderLabel.frame = CGRectMake(3.0f, 7.0f, placeholderLabel.frame.size.width, placeholderLabel.frame.size.height);
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
