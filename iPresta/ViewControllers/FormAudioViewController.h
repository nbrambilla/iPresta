//
//  FormAudioViewController.h
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
@class IPButton;
@class IPCheckbox;
@class IPTextField;

@interface FormAudioViewController : UIViewController <ObjectIPDelegate,  UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate, iPrestaImageViewDelegate, EZFormDelegate>
{
    @private
    EZForm *form;
    IBOutlet UIScrollView *scrollView;
    IBOutlet IPTextField *nameTextField;
    IBOutlet IPTextField *authorTextField;
    IBOutlet IPTextField *audioTypeTextField;
    IBOutlet PHTextView *descriptionTextView;
    IBOutlet iPrestaImageView *imageView;
    IBOutlet IPCheckbox *visibleCheckbox;
    IBOutlet UILabel *visibleLabel;
    ObjectIP *newObject;
    AudioObjectType audioTypeSelectedIndex;
    IMOAutocompletionViewController *autoComplete;
    
    IBOutlet IPButton *searchButton;
    IBOutlet IPButton *detectButton;
    IBOutlet IPButton *addButton;
}

@end
