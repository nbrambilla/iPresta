//
//  AddObjectViewController.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AddObjectViewController.h"

@interface AddObjectViewController ()

@end

@implementation AddObjectViewController

#pragma mark - Lifecycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *detectObjectButton = [[UIBarButtonItem alloc] initWithTitle:@"Detectar" style:UIBarButtonItemStylePlain target:self action:@selector(goToDetectObject)];
    self.navigationItem.rightBarButtonItem = detectObjectButton;
    
    detectObjectButton = nil;
    
    newObject = [iPrestaObject new];
    
    [iPrestaObject setDelegate:self];
    
    typesArray = [iPrestaObject objectTypes];
    audioTypesArray = [iPrestaObject audioObjectTypes];
    videoTypesArray = [iPrestaObject videoObjectTypes];

    [self stComboText:typeComboText didSelectRow:BookType];
}

- (void)goToDetectObject
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
    reader = nil;
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
//    isbnTextField.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
//    resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    [newObject getObjectData:symbol.data];
}

- (void)getObjectDataSuccess
{
    nameTextField.text = newObject.name;
    authorTextField.text = newObject.author;
    editorialTextField.text = newObject.editorial;
}

- (void)viewDidUnload
{
    [iPrestaObject setDelegate:nil];
    descriptionTextField = nil;
    typeComboText = nil;
    nameTextField = nil;
    authorTextField = nil;
    editorialTextField = nil;
    audioTypeComboText = nil;
    videoTypeComboText = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Save Objects Methods

- (IBAction)addToCurrentUser:(id)sender
{
    nameTextField.text = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([nameTextField.text length] > 0)
    {
        newObject.state = Property;
        newObject.type = typeSelectedIndex;
        newObject.name = nameTextField.text;
        newObject.author = authorTextField.text;
        newObject.editorial = editorialTextField.text;
        newObject.description = descriptionTextField.text;
        newObject.audioType = audioTypeSelectedIndex;
        newObject.videoType = videoTypeSelectedIndex;
        
        [newObject addToCurrentUser];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El objeto debe tener al menos el nombre" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)addToCurrentUserSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addObjectToListDelegate" object:newObject];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard Methods

- (IBAction)hideKeyboard:(id)sender
{
    for (UIView *subview in [sender subviews])
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            if ([subview isFirstResponder])
            {
                [subview resignFirstResponder];
                break;
            }
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isKindOfClass:[STComboText class]])
    {
        [(STComboText*)textField showOptions];
        return NO;
    }
    return YES;
}

#pragma mark - STCombo Methods

- (NSString*)stComboText:(STComboText*)stComboText textForRow:(NSUInteger)row
{
    NSString *returnString = nil;
    
    if(stComboText == typeComboText)
    {
        returnString = [typesArray objectAtIndex:row];
    }
    else if (stComboText == audioTypeComboText)
    {
        returnString = [audioTypesArray objectAtIndex:row];
    }
    else if (stComboText == videoTypeComboText)
    {
        returnString = [videoTypesArray objectAtIndex:row];
    }
    
    return returnString;
}

- (NSInteger)stComboText:(STComboText*)stComboTextNumberOfOptions
{
    NSInteger returnInt = 0;
    
    if(stComboTextNumberOfOptions == typeComboText)
    {
        returnInt = typesArray.count;
    }
    else if (stComboTextNumberOfOptions == audioTypeComboText)
    {
        returnInt = audioTypesArray.count;
    }
    else if (stComboTextNumberOfOptions == videoTypeComboText)
    {
        returnInt = videoTypesArray.count;
    }
    
    return returnInt;
}

- (void)stComboText:(STComboText*)stComboText didSelectRow:(NSUInteger)row
{
    if(stComboText == typeComboText)
    {
        typeComboText.text = [typesArray objectAtIndex:row];
        typeSelectedIndex = row;
        [self setObjectTypeFields:row];
    }
    else if(stComboText == audioTypeComboText)
    {
        audioTypeComboText.text = [audioTypesArray objectAtIndex:row];
        audioTypeSelectedIndex = row;
    }
    else if(stComboText == videoTypeComboText)
    {
        videoTypeComboText.text = [videoTypesArray objectAtIndex:row];
        videoTypeSelectedIndex = row;
    }
}

#pragma mark - Private Methods

- (void)setObjectTypeFields:(NSUInteger)objectType
{
    switch (objectType) {
        case BookType:
            [self showBookFields];
            break;
        case AudioType:
            [self showAudioObjectsFields];
            break;
        case VideoType:
            [self showVisualFields];
            break;
        case OtherType:
            [self showOtherFields];
            break;
    }
}

- (void)showBookFields
{
    authorTextField.hidden = NO;
    editorialTextField.hidden = NO;
    audioTypeComboText.hidden = YES;
    videoTypeComboText.hidden = YES;
    
    audioTypeSelectedIndex = NoneAudioObjectType;
    videoTypeSelectedIndex = NoneVideoObjectType;
}

- (void)showAudioObjectsFields
{
    authorTextField.hidden = NO;
    editorialTextField.hidden = YES;
    audioTypeComboText.hidden = NO;
    videoTypeComboText.hidden = YES;
    
    [self stComboText:audioTypeComboText didSelectRow:CDAudioObjectType]; 
    videoTypeSelectedIndex = NoneVideoObjectType;
}

- (void)showVisualFields
{
    authorTextField.hidden = NO;
    editorialTextField.hidden = YES;
    audioTypeComboText.hidden = YES;
    videoTypeComboText.hidden = NO;
    
    audioTypeSelectedIndex = NoneAudioObjectType;
    [self stComboText:videoTypeComboText didSelectRow:DVDVideoObjectType];
}

- (void)showOtherFields
{
    authorTextField.hidden = YES;
    editorialTextField.hidden = YES;
    audioTypeComboText.hidden = YES;
    videoTypeComboText.hidden = YES;
    
    audioTypeSelectedIndex = NoneAudioObjectType;
    videoTypeSelectedIndex = NoneVideoObjectType;
}

@end
