//
//  STDateText.h
//  STCustomControls
//
//  Created by Neon Spark on 09/09/11.
//  Copyright 2011 http://Sugartin.info. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STDatePickerModeTime, 
    STDatePickerModeDate, 
    STDatePickerModeDateAndTime,
    STDatePickerModeCountDownTimer
} STDatePickerMode;

@class STDateText;

@protocol STDateTextDelegate <NSObject>

@required
- (void)stDateText:(STDateText*)STDateText dateChangedTo:(NSDate*)date;

@end



@interface STDateText : UITextField 

@property	(nonatomic, assign)		IBOutlet UIViewController<STDateTextDelegate>	*delegateVCtr;
@property	(nonatomic)				STDatePickerMode			datePickerMode;
@property	(nonatomic,strong)		NSDate						*date;
@property	(nonatomic,strong)		NSDate						*minimumDate;
@property	(nonatomic,retain)		NSDate						*maximumDate;
@property	(nonatomic)				NSTimeInterval				countDownDuration;
@property	(nonatomic)				NSInteger					minuteInterval;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;
- (void)showDatePicker;
@end
