//
//  FormBookViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPrestaObject.h"
#import "User.h"
#import "STControls.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@class PHTextView;
@class TPKeyboardAvoidingScrollView;

@interface FormBookViewController : UIViewController <iPrestaObjectDelegate,  UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet UITextField *editorialTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    iPrestaObject *newObject;
    IMOAutocompletionViewController *autoComplete;
}

@end
