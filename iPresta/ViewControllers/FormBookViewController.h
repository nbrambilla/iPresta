//
//  FormBookViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectIP.h"
#import "UserIP.h"
#import "STControls.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@class PHTextView;
@class TPKeyboardAvoidingScrollView;
@class IPButton;
@class IPCheckbox;

@interface FormBookViewController : UIViewController <UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate, ObjectIPDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet UITextField *editorialTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet IPCheckbox *visibleCheckbox;
    IBOutlet UILabel *visibleLabel;
    ObjectIP *newObject;
    IMOAutocompletionViewController *autoComplete;
    
    IBOutlet IPButton *searchButton;
    IBOutlet IPButton *detectButton;
    IBOutlet IPButton *addButton;
}

@end
