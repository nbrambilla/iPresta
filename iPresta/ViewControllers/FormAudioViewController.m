//
//  FormAudioViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 15/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FormAudioViewController.h"
#import "iPrestaNSError.h"
#import "iPrestaNSString.h"
#import "ProgressHUD.h"
#import "PHTextView.h"

@interface FormAudioViewController ()

@end

@implementation FormAudioViewController

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
    
    [self setView];
}

- (void)setView
{
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    authorTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    descriptionTextView.placeholder = @"Descripción";
    
    newObject = [iPrestaObject object];
    
    audioTypesArray = [iPrestaObject audioObjectTypes];
    [self stComboText:audioTypeComboText didSelectRow:CDAudioObjectTypee];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    newObject.delegate = self;
}

- (void)viewDidUnload
{
    descriptionTextView = nil;
    nameTextField = nil;
    authorTextField = nil;
    audioTypesArray = nil;
    newObject = nil;
    imageView = nil;
    visibleSwitch = nil;
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Detect Object Methods

- (IBAction)detectObject:(id)sender
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
    reader = nil;
}

- (void)tapImageView
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        
        imagePicker.delegate = self;
        
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
        
        newObject.imageData = nil;
        if ([symbol.data isValidBarcode]) [self getObjectDataWithCode:symbol.data];
    }
    else
    {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        UIGraphicsBeginImageContext(CGSizeMake(248, 248));
        [image drawInRect: CGRectMake(0, 0, 248, 248)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [imageView setImage:smallImage];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFields Methods

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

- (NSString *)stComboText:(STComboText *)stComboText textForRow:(NSUInteger)row
{
    NSString *returnString = nil;
    
    if (stComboText == audioTypeComboText)
    {
        returnString = [audioTypesArray objectAtIndex:row];
    }
    
    return returnString;
}

- (NSInteger)stComboText:(STComboText *)stComboTextNumberOfOptions
{
    NSInteger returnInt = 0;
    
    if (stComboTextNumberOfOptions == audioTypeComboText)
    {
        returnInt = audioTypesArray.count;
    }
    
    return returnInt;
}

- (void)stComboText:(STComboText *)stComboText didSelectRow:(NSUInteger)row
{
    if(stComboText == audioTypeComboText)
    {
        audioTypeComboText.text = [audioTypesArray objectAtIndex:row];
        audioTypeSelectedIndex = row;
    }
}

- (void)getObjectDataWithCode:(NSString *)code
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [newObject getData:code];
}

#pragma mark - IMOAutoCompletionViewDataSource Methods;

- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset
{
    [newObject getSearchResults:param page:page offset:offset];
}

#pragma mark - IMOAutoCompletionViewDelegate Methods;

- (void)IMOAutocompletionViewControllerReturnedCompletion:(id)object
{
    if (object)
    {
        newObject = (iPrestaObject *)object;
        [self setFields];
        [self setNewObject];
    }
}

#pragma mark - Save Objects Methods

- (IBAction)addObject:(id)sender
{
    nameTextField.text = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([nameTextField.text length] > 0)
    {
        [self setNewObject];
        
        if (![[User currentUser] hasObject:newObject] )
        {
            [self saveNewObject];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Este objeto ya ha sido registrado" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            alert = nil;
        }
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
             [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
             
             NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:newObject.type], @"type", nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
             options = nil;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCountLabelsObserver" object:nil];
             
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

#pragma mark - Set Methods

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    authorTextField.text = [newObject.author capitalizedString];
    
    [imageView deleteImage];
    
    if (newObject.imageURL && newObject.imageData == nil)
    {
        UIActivityIndicatorView *indicatorImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorImage.frame = imageView.bounds;
        [indicatorImage setHidesWhenStopped:YES];
        [indicatorImage startAnimating];
        [imageView addSubview:indicatorImage];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^(void)
        {
           newObject.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newObject.imageURL]];
           [indicatorImage stopAnimating];
           UIImage* image = [UIImage imageWithData:newObject.imageData];
           if (image)
           {
               [imageView setImage:image];
           }
        });
    }
    
    else if (newObject.imageData)
    {
        [imageView setImage:[UIImage imageWithData:newObject.imageData]];
    }
}

#pragma mark - iPrestaObjectDelegate Methods

- (void)getSearchResultsResponse:(NSArray *)searchResults withError:(NSError *)error
{
    [autoComplete loadSearchTableWithResults:searchResults error:error];
}

- (void)getDataResponseWithError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];
    else [self setFields];
}

- (void)setNewObject
{
    newObject.owner = [User currentUser];
    newObject.type = [iPrestaObject typeSelected];
    newObject.state = Propertye;
    newObject.name = nameTextField.text;
    newObject.visible = visibleSwitch.isOn;
    
    if (imageView.isSetted)
    {
        NSData *imageData = UIImageJPEGRepresentation([imageView getImage], 0.1f);
        newObject.image = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", [[iPrestaObject objectTypes] objectAtIndex:[iPrestaObject typeSelected]]] data:imageData];
        
        [newObject.image saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) [error manageErrorTo:self];
        }];
        
        imageData = nil;
    }
    if (authorTextField.text) newObject.author = [authorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (audioTypeSelectedIndex != NoneAudioObjectTypee) newObject.audioType = audioTypeSelectedIndex;
}

#pragma mark - Button Methods

- (IBAction)searchObject:(id)sender
{
    autoComplete = [[IMOAutocompletionViewController alloc] initWithCancelButton:YES andPagination:YES];
    
    [autoComplete setDataSource:self];
    [autoComplete setDelegate:self];
    [autoComplete setTitle:@"Buscar"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:autoComplete];
    [[self navigationController] presentModalViewController:navController animated:YES];
}

@end
