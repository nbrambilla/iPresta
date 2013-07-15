//
//  FormAudioViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 15/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPrestaObject.h"
#import "User.h"
#import "STControls.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"

@class PHTextView;
@class TPKeyboardAvoidingScrollView;

@interface FormAudioViewController : UIViewController <iPrestaObjectDelegate,  UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet STComboText *audioTypeComboText;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    iPrestaObject *newObject;
    NSArray *audioTypesArray;
    AudioObjectType audioTypeSelectedIndex;
    IMOAutocompletionViewController *autoComplete;
}

@end
