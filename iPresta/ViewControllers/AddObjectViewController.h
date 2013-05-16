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

@interface AddObjectViewController : UIViewController <iPrestaObjectDelegate, STComboTextDelegate, UITextFieldDelegate, ZBarReaderDelegate>
{
    @private
    IBOutlet STComboText *typeComboText;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *authorTextField;
    IBOutlet UITextField *descriptionTextField;
    IBOutlet UITextField *editorialTextField;
    IBOutlet STComboText *audioTypeComboText;
    IBOutlet STComboText *videoTypeComboText;
    iPrestaObject *newObject;
    NSArray *typesArray;
    NSArray *audioTypesArray;
    NSArray *videoTypesArray;
    ObjectType typeSelectedIndex;
    AudioObjectType audioTypeSelectedIndex;
    VideoObjectType videoTypeSelectedIndex;
}

@end
