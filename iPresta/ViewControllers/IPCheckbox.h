//
//  IPCheckbox.h
//  iPresta
//
//  Created by Nacho Brambilla  on 15/05/14.
//  Copyright (c) 2014 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IPCheckboxDelegate <NSObject>

@optional
- (void)checkboxChangeState;

@end

@interface IPCheckbox : UIButton

@property (nonatomic, retain) id <IPCheckboxDelegate> delegate;

@end
