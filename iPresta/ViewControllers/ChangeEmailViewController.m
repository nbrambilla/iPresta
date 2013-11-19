//
//  ChangeEmailViewController.m
//  iPresta
//
//  Created by Nacho on 27/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "iPrestaNSString.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "Language.h"

@interface ChangeEmailViewController ()

@end

@implementation ChangeEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [Language get:@"Cambiar email" alter:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    changeMailTextLabel.text = [NSString stringWithFormat:@"Su email actual es %@. Si desea cambiarlo, ingrese el nuevo y presione \"Cambiar email\"", [UserIP email]];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
}

- (IBAction)changeEmail:(id)sender
{
    if ([emailTextField.text isValidEmail])
    {
        [ProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [UserIP setEmail:emailTextField.text];
        [UserIP save];
    }
}

- (void)saveResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];  // Si hay error en el cambio de email
    else [self changeEmailSuccess];
}

- (void)changeEmailSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"Email cambiado" alter:nil] message:[Language get:@"Mensaje autenticar" alter:nil] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}

- (IBAction)hideKeyboard:(id)sender
{
    if ([emailTextField isFirstResponder]) [emailTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    emailTextField = nil;
    changeMailTextLabel = nil;
    [super viewDidUnload];
}
@end
