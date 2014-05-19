//
//  FormOtherViewController.h
//  iPresta
//
//  Created by Nacho Brambilla on 15/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZForm/EZForm.h>
#import "ObjectIP.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"

@class PHTextView;
@class TPKeyboardAvoidingScrollView;
@class IPButton;
@class IPCheckbox;
@class IPTextField;

@interface FormOtherViewController : UIViewController <ObjectIPDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, iPrestaImageViewDelegate, EZFormDelegate>
{
    @private
    EZForm *form;
    IBOutlet UIScrollView *scrollView;
    IBOutlet IPTextField *nameTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet IPCheckbox *visibleCheckbox;
    IBOutlet UILabel *visibleLabel;
    ObjectIP *newObject;
    
    IBOutlet IPButton *addButton;
}

@end
