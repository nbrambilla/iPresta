//
//  FormBookViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 20/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FormBookViewController.h"
#import "iPrestaNSError.h"
#import "iPrestaNSString.h"
#import "ProgressHUD.h"
#import "PHTextView.h"
#import "IPButton.h"
#import "IPCheckbox.h"
#import "IPTextField.h"

@interface FormBookViewController ()

@end

@implementation FormBookViewController

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
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
    
    [self setView];
}

- (void)setView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = IPString(@"Anadir");
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    authorTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    editorialTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    nameTextField.placeholder = IPString(@"Nombre");
    authorTextField.placeholder = IPString(@"Autor");
    editorialTextField.placeholder = IPString(@"Editorial");
    visibleLabel.text = IPString(@"Visible");
    
    visibleCheckbox.selected = YES;
    
//    CGRect frame = scrollView.frame;
//    frame.size.height = (IS_IPHONE_4_INCHES) ? 504.0f : 416.0f;
//    scrollView.frame = frame;
//    scrollView.contentSize = frame.size;
    
    [searchButton setTitle:IPString(@"Buscar") forState:UIControlStateNormal];
    [detectButton setTitle:IPString(@"Detectar") forState:UIControlStateNormal];
    [addButton setTitle:IPString(@"Anadir") forState:UIControlStateNormal];
    
    descriptionTextView.placeholder = IPString(@"Descripcion");
    
    // Set Form
    
    form = [EZForm new];
    form.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    form.delegate = self;
    
    EZFormTextField *nameField = [[EZFormTextField alloc] initWithKey:@"name"];
    nameField.validationMinCharacters = 1;
    nameField.inputMaxCharacters = 100;

    EZFormTextField *authorField = [[EZFormTextField alloc] initWithKey:@"author"];
    authorField.validationMinCharacters = 0;
    authorField.inputMaxCharacters = 100;

    EZFormTextField *editorialField = [[EZFormTextField alloc] initWithKey:@"editorial"];
    editorialField.validationMinCharacters = 0;
    editorialField.inputMaxCharacters = 50;
    
    EZFormTextField *descriptionField = [[EZFormTextField alloc] initWithKey:@"description"];
    descriptionField.validationMinCharacters = 0;
    descriptionField.inputMaxCharacters = 200;

    [form addFormField:nameField];
    [form addFormField:authorField];
    [form addFormField:editorialField];
    [form addFormField:descriptionField];
    
    [nameField useTextField:nameTextField];
    [authorField useTextField:authorTextField];
    [editorialField useTextField:editorialTextField];
    [descriptionField useTextView:descriptionTextView];
    
    [form autoScrollViewForKeyboardInput:scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
    
    [self checkValidForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Detect Object Methods

- (IBAction)detectObject:(id)sender
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
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

- (void)getObjectDataWithCode:(NSString *)code
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [newObject getData:code];
}

- (void)checkValidForm
{
    addButton.enabled = (form.isFormValid) ? YES : NO;
}

#pragma mark - ObjectIPDelegate Methods

- (void)getSearchResultsResponse:(NSArray *)searchResults withError:(NSError *)error
{
    NSDictionary *params = (searchResults) ? @{@"objects": searchResults} : nil;
    [autoComplete loadSearchTableWithResults:params error:error];
}

- (void)getDataResponseWithError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];
    else [self setFields];
}

#pragma mark - Set Methods

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    [form setModelValue:nameTextField.text forKey:@"name"];
    authorTextField.text = [newObject.author capitalizedString];
    [form setModelValue:authorTextField.text forKey:@"author"];
    editorialTextField.text = [newObject.editorial capitalizedString];
    [form setModelValue:editorialTextField.text forKey:@"editorial"];
    
    [imageView deleteImage];
    
    if (newObject.imageURL) [imageView setImageWithURL:newObject.imageURL];
    else [imageView setImage:[UIImage imageNamed:IMAGE_TYPES[newObject.type.integerValue]]];
}

- (IBAction)addObject:(id)sender
{
    newObject.name = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    newObject.type = @([ObjectIP selectedType]);
    newObject.state = @(Property);
    newObject.visible = @(visibleCheckbox.selected);
    NSData *imageData = nil;
    if (imageView.isSetted) imageData = UIImagePNGRepresentation([imageView getImage]);
    if (editorialTextField.text) newObject.editorial = [editorialTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (authorTextField.text) newObject.author = [authorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [newObject addObjectWithImageData:imageData];
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
    [error manageError];      // Si hay error al actualizar el objeto
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

#pragma mark - Search Methods

- (IBAction)searchObject:(id)sender
{
    autoComplete = [[IMOAutocompletionViewController alloc] initWithCancelButton:YES andPagination:YES];
    
    [autoComplete setDataSource:self];
    [autoComplete setDelegate:self];
    [autoComplete setTitle:@"Buscar"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:autoComplete];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

# pragma mark - EZFormDelegate Methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
    [self checkValidForm];
}

# pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
