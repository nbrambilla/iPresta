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

#import <QuartzCore/QuartzCore.h>

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
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    authorTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    editorialTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    nameTextField.placeholder = NSLocalizedString(@"Nombre", nil);
    authorTextField.placeholder = NSLocalizedString(@"Autor", nil);
    nameTextField.placeholder = NSLocalizedString(@"Editorial", nil);
    
    [searchButton setTitle:NSLocalizedString(@"Buscar", nil) forState:UIControlStateNormal];
    [detectButton setTitle:NSLocalizedString(@"Detectar", nil) forState:UIControlStateNormal];
    [addButton setTitle:NSLocalizedString(@"Anadir", nil) forState:UIControlStateNormal];
    
    descriptionTextView.placeholder = NSLocalizedString(@"Descripcion", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    newObject = nil;
    descriptionTextView = nil;
    nameTextField = nil;
    authorTextField = nil;
    editorialTextField = nil;
    newObject = nil;
    imageView = nil;
    visibleSwitch = nil;
    [super viewDidUnload];
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

- (void)getObjectDataWithCode:(NSString *)code
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [newObject getData:code];
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
    
    if (error) [error manageErrorTo:self];
    else [self setFields];
}

#pragma mark - Set Methods

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    authorTextField.text = [newObject.author capitalizedString];
    editorialTextField.text = [newObject.editorial capitalizedString];
    
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
                           UIImage* image = [UIImage imageWithData:newObject.image];
                           if (image)
                           {
                               [imageView setImage:image];
                           }
                       });
    }
    
    else if (newObject.image) [imageView setImage:[UIImage imageWithData:newObject.image]];
}

- (IBAction)addObject:(id)sender
{
    newObject.name = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newObject.name length] > 0)
    {
        [ProgressHUD showHUDAddedTo:self.view animated:YES];
        
        newObject.type = [NSNumber numberWithInteger:[ObjectIP selectedType]];
        newObject.state = [NSNumber numberWithInteger:Property];
        newObject.visible = [NSNumber numberWithBool:visibleSwitch.isOn];
        if (imageView.isSetted) newObject.image = UIImagePNGRepresentation([imageView getImage]);
        if (editorialTextField.text) newObject.editorial = [editorialTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

@end
