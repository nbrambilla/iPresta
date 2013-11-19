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
#import "Language.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
}

- (void)setView
{
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    authorTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    nameTextField.placeholder = [Language get:@"Nombre" alter:nil];
    authorTextField.placeholder = [Language get:@"Autor" alter:nil];
    nameTextField.placeholder = [Language get:@"Nombre" alter:nil];
    
    [searchButton setTitle:[Language get:@"Buscar" alter:nil] forState:UIControlStateNormal];
    [detectButton setTitle:[Language get:@"Detectar" alter:nil] forState:UIControlStateNormal];
    [addButton setTitle:[Language get:@"Anadir" alter:nil] forState:UIControlStateNormal];
    
    descriptionTextView.placeholder = [Language get:@"Descripcion" alter:nil];
    
    audioTypesArray = [ObjectIP audioObjectTypes];
    [self stComboText:audioTypeComboText didSelectRow:CDAudioObjectType];
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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
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
        newObject = object;
        [self setFields];
    }
}

#pragma mark - Save Objects Methods

- (IBAction)addObject:(id)sender
{
    newObject.name = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newObject.name length] > 0)
    {
        [ProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if (audioTypeSelectedIndex != NoneAudioObjectType) newObject.audioType = [NSNumber numberWithInteger:audioTypeSelectedIndex];
        newObject.type = [NSNumber numberWithInteger:[ObjectIP selectedType]];
        newObject.state = [NSNumber numberWithInteger:Property];
        newObject.visible = [NSNumber numberWithBool:visibleSwitch.isOn];
        if (imageView.isSetted) newObject.image = UIImagePNGRepresentation([imageView getImage]);
        if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (authorTextField.text) newObject.author = [authorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [newObject addObject];
    }
}

- (void)addObjectSuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:newObject.type, @"type", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
    options = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCountLabelsObserver" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)objectError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [error manageErrorTo:self];      // Si hay error al actualizar el objeto
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

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    authorTextField.text = [newObject.author capitalizedString];
    
    [imageView deleteImage];
    
    if (newObject.imageURL && newObject.image == nil)
    {
        UIActivityIndicatorView *indicatorImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorImage.frame = imageView.bounds;
        [indicatorImage setHidesWhenStopped:YES];
        [indicatorImage startAnimating];
        [imageView addSubview:indicatorImage];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^(void)
                       {
                           newObject.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:newObject.imageURL]];
                           [indicatorImage stopAnimating];
                           NSLog(@"%@ %@", newObject.image, newObject.imageURL);
                           UIImage* image = [UIImage imageWithData:newObject.image];
                           if (image)
                           {
                               [imageView setImage:image];
                           }
                       });
    }
    
    else if (newObject.image) [imageView setImage:[UIImage imageWithData:newObject.image]];
}

#pragma mark - Button Methods

- (IBAction)searchObject:(id)sender
{
    autoComplete = [[IMOAutocompletionViewController alloc] initWithCancelButton:YES andPagination:YES];
    
    [autoComplete setDataSource:self];
    [autoComplete setDelegate:self];
    [autoComplete setTitle:[Language get:@"Buscar" alter:nil]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:autoComplete];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
