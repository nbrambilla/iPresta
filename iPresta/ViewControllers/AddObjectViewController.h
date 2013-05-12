//
//  AddObjectViewController.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPrestaObject.h"
#import "STControls.h"
#import "ZBarSDK.h"

@interface AddObjectViewController : UIViewController <iPrestaObjectDelegate, STComboTextDelegate, UITextFieldDelegate, ZBarReaderDelegate>
{
    __weak IBOutlet STComboText *typeComboText;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITextField *authorTextField;
    __weak IBOutlet UITextField *descriptionTextField;
    __weak IBOutlet UITextField *editorialTextField;
    __weak IBOutlet STComboText *audioTypeComboText;
    __weak IBOutlet STComboText *videoTypeComboText;
    
    iPrestaObject *newObject;
    
    NSArray *typesArray;
    NSArray *audioTypesArray;
    NSArray *videoTypesArray;
    
    ObjectType typeSelectedIndex;
    AudioObjectType audioTypeSelectedIndex;
    VideoObjectType videoTypeSelectedIndex;
}

@end
