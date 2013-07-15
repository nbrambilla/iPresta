//
//  FormOtherViewController.h
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

@interface FormOtherViewController : UIViewController <iPrestaObjectDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    iPrestaObject *newObject;
}

@end
