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
    
    descriptionTextView.placeholder = @"Descripción";
    
    newObject = [iPrestaObject object];
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

- (void)setNewObject
{
    newObject.owner = [User currentUser];
    newObject.type = [iPrestaObject typeSelected];
    newObject.state = Property;
    newObject.name = nameTextField.text;
    
    if (imageView.isSetted)
    {
        NSData *imageData = UIImageJPEGRepresentation([imageView getImage], 0.1f);
        newObject.image = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", [[iPrestaObject objectTypes] objectAtIndex:[iPrestaObject typeSelected]]] data:imageData];
        
        [newObject.image saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) [error manageErrorTo:self];
        }];
        
        imageData = nil;
    }
    if (descriptionTextView.text) newObject.descriptionObject = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
