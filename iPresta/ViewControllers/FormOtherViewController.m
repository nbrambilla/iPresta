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
#import "Language.h"

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

- (void)setView
{
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    nameTextField.placeholder = [Language get:@"Nombre" alter:nil];
    
    [addButton setTitle:[Language get:@"Anadir" alter:nil] forState:UIControlStateNormal];
    
    descriptionTextView.placeholder = [Language get:@"Descripcion" alter:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    newObject = [[ObjectIP alloc] initListObject];
    [ObjectIP setDelegate:self];
}

- (void)viewDidUnload
{
    descriptionTextView = nil;
    nameTextField = nil;
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
    
    if ([newObject.name length] > 0)
    {
        [ProgressHUD showHUDAddedTo:self.view animated:YES];
        
        newObject.type = [NSNumber numberWithInteger:[ObjectIP selectedType]];
        newObject.state = [NSNumber numberWithInteger:Property];
        newObject.visible = [NSNumber numberWithBool:visibleSwitch.isOn];
        if (imageView.isSetted) newObject.image = UIImagePNGRepresentation([imageView getImage]);
        if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
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

#pragma mark - Set Methods

- (void)setFields
{
    nameTextField.text = [newObject.name capitalizedString];
    
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


@end
