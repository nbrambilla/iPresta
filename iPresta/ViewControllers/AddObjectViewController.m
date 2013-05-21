//
//  AddObjectViewController.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AddObjectViewController.h"
#import "iPrestaNSError.h"
#import "iPrestaNSString.h"
#import "ProgressHUD.h"

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
    
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    authorTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    editorialTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    descriptionTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraPressed)];
    [imageView addGestureRecognizer:tapGesture];
    imageView.tag = NO;
    
    newObject = [iPrestaObject object];
    newObject.type = [iPrestaObject typeSelected];
    newObject.delegate = self;
    
    audioTypesArray = [iPrestaObject audioObjectTypes];
    videoTypesArray = [iPrestaObject videoObjectTypes];
    
    [self setObjectTypeFields:[iPrestaObject typeSelected]];
}

- (void)viewDidUnload
{
    descriptionTextField = nil;
    nameTextField = nil;
    authorTextField = nil;
    editorialTextField = nil;
    audioTypeComboText = nil;
    videoTypeComboText = nil;
    imageView = nil;
    newObject = nil;
    imageView = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Detect Object Methods

- (void)goToDetectObject
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;

    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
    reader = nil;
}

- (void)cameraPressed
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentModalViewController:imagePicker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info objectForKey:ZBarReaderControllerResults])
    {
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results) break;
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        [self getObjectDataWithCode:symbol.data];
    }
    else
    {
        // Access the uncropped image from info dictionary
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(248, 248));
        [image drawInRect: CGRectMake(0, 0, 248, 248)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        imageView.image = smallImage;
        imageView.tag = YES;
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)getObjectDataWithCode:(NSString *)code
{
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [newObject getData:code];
}

- (void)getDataResponseWithError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view.window animated:YES];
    
    if (error) [error manageErrorTo:self];
    [self setTextFields];
}

#pragma mark - Save Objects Methods

- (IBAction)pressAddToCurrentUser:(id)sender
{
    nameTextField.text = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([nameTextField.text length] > 0)
    {
        [self setNewObject];
        [self saveNewObject];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El objeto debe tener al menos el nombre" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)saveNewObject
{
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    [newObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view.window animated:YES];
         
        if (error) [error manageErrorTo:self];      // Si hay al guardar el objeto
        else                                        // Si el objeto se guarda correctamente
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addObjectToListObserver" object:newObject];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
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

#pragma mark - Set Methods

- (void)setTextFields
{
    nameTextField.text = [newObject.name capitalizedString];
    authorTextField.text = [newObject.author capitalizedString];
    editorialTextField.text = [newObject.editorial capitalizedString];
}

- (void)setNewObject
{
    newObject.owner = [User currentUser];
    newObject.state = Property;
    newObject.name = nameTextField.text;

    if (imageView.tag)
    {
        NSData *imageData = UIImageJPEGRepresentation(imageView.image, 0.5f);
        newObject.image = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", [nameTextField.text formatName]] data:imageData];
        
        [newObject.image saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) [error manageErrorTo:self];
        }];
         
        imageData = nil;
    }
    if (authorTextField.text) newObject.author = [authorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (editorialTextField.text) newObject.editorial = [editorialTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descriptionTextField.text) newObject.descriptionObject = [descriptionTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (audioTypeSelectedIndex != NoneAudioObjectType) newObject.audioType = audioTypeSelectedIndex;
    if (videoTypeSelectedIndex != NoneVideoObjectType) newObject.videoType = videoTypeSelectedIndex;
}

#pragma mark - STCombo Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isKindOfClass:[STComboText class]])
    {
        [(STComboText*)textField showOptions];
        return NO;
    }
    return YES;
}

- (NSString*)stComboText:(STComboText*)stComboText textForRow:(NSUInteger)row
{
    NSString *returnString = nil;
    
    if (stComboText == audioTypeComboText)
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
    
    if (stComboTextNumberOfOptions == audioTypeComboText)
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
    if(stComboText == audioTypeComboText)
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
    switch ([iPrestaObject typeSelected]) {
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
