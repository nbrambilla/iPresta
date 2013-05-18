//
//  AddObjectViewController.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AddObjectViewController.h"
#import "iPrestaNSError.h"
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
    
    newObject = [iPrestaObject object];
    
    [iPrestaObject setDelegate:self];
    
    typesArray = [iPrestaObject objectTypes];
    audioTypesArray = [iPrestaObject audioObjectTypes];
    videoTypesArray = [iPrestaObject videoObjectTypes];

    [self stComboText:typeComboText didSelectRow:BookType];
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
    newObject = nil;
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

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) break;
    
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    [self getObjectDataWithCode:symbol.data];
}

- (void)getObjectDataWithCode:(NSString *)code
{
    [ProgressHUD showHUDAddedTo:self.view.window animated:NO];
    [newObject getData:code];
}

- (void)getDataResponseWithError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view.window animated:YES];
    
    if (error) [error manageErrorTo:self];
    else [self setTextFields];
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
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [newObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
         
        if (error) [error manageErrorTo:self];      // Si hay al guardar el objeto
        else                                        // Si el objeto se guarda correctamente
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addObjectToListDelegate" object:newObject];
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
    newObject.type = typeSelectedIndex;
    newObject.name = nameTextField.text;
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
