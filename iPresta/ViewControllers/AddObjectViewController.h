//
//  AddObjectViewController.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPrestaObject.h"
#import "User.h"
#import "STControls.h"
#import "ZBarSDK.h"
#import "iPrestaImageView.h"
#import "IMOAutocompletionViewController.h"

@interface AddObjectViewController : UIViewController <iPrestaObjectDelegate, STComboTextDelegate, UITextFieldDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate>
{
    @private
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet UITextField *descriptionTextField;
    IBOutlet UITextField *editorialTextField;
    IBOutlet STComboText *audioTypeComboText;
    IBOutlet STComboText *videoTypeComboText;
    iPrestaImageView *imageView;
    iPrestaObject *newObject;
    NSArray *audioTypesArray;
    NSArray *videoTypesArray;
    ObjectType objecType;
    AudioObjectType audioTypeSelectedIndex;
    VideoObjectType videoTypeSelectedIndex;
    IMOAutocompletionViewController *autoComplete;
}

@end
