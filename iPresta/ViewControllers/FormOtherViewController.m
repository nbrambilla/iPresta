//
//  FormOtherViewController.m
//  iPresta
//
//  Created by Nacho Brambilla on 15/07/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "FormOtherViewController.h"
#import "iPrestaNSError.h"
#import "iPrestaNSString.h"
#import "ProgressHUD.h"
#import "PHTextView.h"
#import "IPButton.h"
#import "IPCheckbox.h"
#import "IPTextField.h"

@interface FormOtherViewController ()

@end

@implementation FormOtherViewController

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
    
    [self checkValidForm];
}

- (void)setView
{
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    nameTextField.placeholder = NSLocalizedString(@"Nombre", nil);
    visibleLabel.text = NSLocalizedString(@"Visible", nil);
    
    visibleCheckbox.selected = YES;
    
    CGRect frame = scrollView.frame;
    frame.size.height = (IS_IPHONE5) ? 504.0f : 416.0f;
    scrollView.frame = frame;
    scrollView.contentSize = frame.size;
    
    [addButton setTitle:NSLocalizedString(@"Anadir", nil) forState:UIControlStateNormal];
    
    descriptionTextView.placeholder = NSLocalizedString(@"Descripcion", nil);
    
    // Set Form
    
    form = [EZForm new];
    form.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    form.delegate = self;
    
    EZFormTextField *nameField = [[EZFormTextField alloc] initWithKey:@"name"];
    nameField.validationMinCharacters = 1;
    nameField.inputMaxCharacters = 100;
    
    EZFormTextField *descriptionField = [[EZFormTextField alloc] initWithKey:@"description"];
    descriptionField.validationMinCharacters = 0;
    descriptionField.inputMaxCharacters = 200;
    
    [form addFormField:nameField];
    [form addFormField:descriptionField];
    
    [nameField useTextField:nameTextField];
    [descriptionField useTextView:descriptionTextView];
    
    [form autoScrollViewForKeyboardInput:scrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkValidForm
{
    addButton.enabled = (form.isFormValid) ? YES : NO;
}

#pragma mark - Detect Object Methods

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
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    UIGraphicsBeginImageContext(CGSizeMake(248, 248));
    [image drawInRect: CGRectMake(0, 0, 248, 248)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView setImage:smallImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save Objects Methods

- (IBAction)addObject:(id)sender
{
    newObject.name = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    newObject.type = @([ObjectIP selectedType]);
    newObject.state = @(Property);
    newObject.visible = @(visibleCheckbox.selected);
    if (imageView.isSetted) newObject.image = UIImagePNGRepresentation([imageView getImage]);
    if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [newObject addObject];
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

#pragma mark - Set Methods

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    
    [imageView deleteImage];
    
    if (newObject.imageURL && newObject.image == nil) [imageView setImageWithURL:newObject.imageURL];
    else if (newObject.image) [imageView setImage:[UIImage imageWithData:newObject.image]];
}

# pragma mark - EZFormDelegate Methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
    [self checkValidForm];
}

@end
