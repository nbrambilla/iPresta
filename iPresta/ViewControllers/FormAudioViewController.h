//
//  FormAudioViewController.h
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
@class IPButton;
@class IPCheckbox;

@interface FormAudioViewController : UIViewController <ObjectIPDelegate,  UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet STComboText *audioTypeComboText;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet IPCheckbox *visibleCheckbox;
    IBOutlet UILabel *visibleLabel;
    ObjectIP *newObject;
    NSArray *audioTypesArray;
    AudioObjectType audioTypeSelectedIndex;
    IMOAutocompletionViewController *autoComplete;
    
    IBOutlet IPButton *searchButton;
    IBOutlet IPButton *detectButton;
    IBOutlet IPButton *addButton;
}

@end
