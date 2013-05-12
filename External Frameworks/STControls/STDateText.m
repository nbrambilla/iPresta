//
//  STDateText.m
//  STCustomControls
//
//  Created by Neon Spark on 09/09/11.
//  Copyright 2011 http://Sugartin.info. All rights reserved.
//

#import "STDateText.h"

@interface STDateText () <UIActionSheetDelegate>  {
	UIActionSheet *action;
}
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *viewOfPicker;
@property (nonatomic, strong) UIToolbar *tBar;
@end


@implementation STDateText

// private
@synthesize datePicker = _datePicker;
@synthesize viewOfPicker = _viewOfPicker;
@synthesize tBar = _tBar;

// public
@synthesize delegateVCtr = _delegateVCtr;
@synthesize datePickerMode = _datePickerMode;
@synthesize date = _date;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize countDownDuration = _countDownDuration;
@synthesize minuteInterval = _minuteInterval;

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
	[self.delegateVCtr stDateText:self dateChangedTo:date];
	[self.datePicker setDate:date animated:animated];
}

#define kTagToolBar		1
#define kTagDatePicker	2

- (void)showDatePicker {
	if(!self.viewOfPicker) {
		self.viewOfPicker=[[UIView alloc] init]; 
		self.datePicker=[[UIDatePicker alloc] init]; 
		self.datePicker.tag=kTagDatePicker;
		
		[self.viewOfPicker addSubview:self.datePicker];
		
		self.tBar=[[UIToolbar alloc] init ];
		UIBarButtonItem *itemCancel=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clear)];
		UIBarButtonItem *itemFlex=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *itemDone=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		[self.tBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
		[self.tBar setItems:[NSArray arrayWithObjects:itemCancel,itemFlex,itemDone, nil] animated:YES];
		self.tBar.tag=kTagToolBar;
		[self.viewOfPicker addSubview:self.tBar];
		[self.datePicker addTarget:self action:@selector(datechanged:) forControlEvents:UIControlEventValueChanged];
	}
	
	if(UIInterfaceOrientationIsLandscape([self.delegateVCtr interfaceOrientation])){
		self.viewOfPicker.frame=CGRectMake(0, 0, 480, 230);
		self.datePicker.frame=CGRectMake(0, 44, 480, 216);
		self.tBar.frame=CGRectMake(0, 0, 480, 44);
	} else {
		self.viewOfPicker.frame=CGRectMake(0, 0, 320, 240);
		self.datePicker.frame=CGRectMake(0, 44, 320, 216);
		self.tBar.frame=CGRectMake(0, 0, 320, 44);
	}
	
	self.datePicker.minimumDate=self.minimumDate;
	self.datePicker.maximumDate=self.maximumDate;
	self.datePicker.countDownDuration=self.countDownDuration;
	self.datePicker.minuteInterval=self.minuteInterval;
	self.datePicker.datePickerMode=(unsigned int)self.datePickerMode;
	
	if(self.date) {
		self.datePicker.date=self.date;
	}
	
	action=[[UIActionSheet alloc] initWithTitle:@"SugarTin.info" delegate:self cancelButtonTitle:@"SugarTin.info" destructiveButtonTitle:@"SugarTin.info" otherButtonTitles:@"SugarTin.info", nil];
		
	[action addSubview:self.viewOfPicker];
	
	[action showInView:self.delegateVCtr.view];
	
	self.datePicker.date=[NSDate date];
}

- (void)clear {
	[self setText:@""];
	[action dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)done {
	[action dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)changeToolBarColor:(UIColor*)color
{
	[self.tBar setTintColor:color];
}

- (void)datechanged:(UIDatePicker*)datePicker 
{
	[self.delegateVCtr stDateText:self dateChangedTo:[datePicker date]];
}

@end
