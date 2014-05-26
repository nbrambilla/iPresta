//
//  PHTextView.h
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHTextView : UITextView <UITextViewDelegate>
{
    @private
    UILabel *placeholderLabel;
}

@property(retain, nonatomic) NSString *placeholder;

@end
