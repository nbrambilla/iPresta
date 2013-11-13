//
//  FormOtherViewController.h
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

@interface FormOtherViewController : UIViewController <ObjectIPDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, iPrestaImageViewDelegate>
{
    @private
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UITextField *nameTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet UISwitch *visibleSwitch;
    ObjectIP *newObject;
    
    IBOutlet UIButton *addButton;
}

@end
