//
//  FormVideoViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 15/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"
#import "STControls.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"

@class PHTextView;
@class TPKeyboardAvoidingScrollView;

@interface FormVideoViewController : UIViewController <ObjectIPDelegate,  UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet STComboText *videoTypeComboText;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet UISwitch *visibleSwitch;
    ObjectIP *newObject;
    NSArray *videoTypesArray;
    VideoObjectType videoTypeSelectedIndex;
    IMOAutocompletionViewController *autoComplete;
    
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *detectButton;
    IBOutlet UIButton *addButton;
}

@end