//
//  STComboText.h
//  ComboBox
//
//  Created by Neon Spark on 08/09/11.
//  Copyright 2011 http://Sugartin.info. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STComboText;

@protocol STComboTextDelegate <NSObject>
@required
- (NSString*)stComboText:(STComboText*)stComboText textForRow:(NSUInteger)row;
- (NSInteger)stComboText:(STComboText*)stComboTextNumberOfOptions;
- (void)stComboText:(STComboText*)stComboText didSelectRow:(NSUInteger)row;
@end

@interface STComboText : UITextField

@property (nonatomic, assign) IBOutlet UIViewController<STComboTextDelegate> *delegateVCtr;
@property (nonatomic) BOOL defaultFirstSelect;

- (void)showOptions;
- (void)changeToolBarColor:(UIColor*)color;

@end
