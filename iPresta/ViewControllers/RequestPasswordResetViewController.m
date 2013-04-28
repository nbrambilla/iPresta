//
//  RequestPasswordResetViewController.m
//  iPresta
//
//  Created by Nacho on 28/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSString.h"
#import "RequestPasswordResetViewController.h"

@interface RequestPasswordResetViewController ()

@end

@implementation RequestPasswordResetViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    emailTextField = nil;
    [super viewDidUnload];
}

- (IBAction)hideKeyboard:(id)sender
{
    if ([emailTextField isFirstResponder]) [emailTextField resignFirstResponder];
}

- (IBAction)requestPasswordReset:(id)sender
{
    if ([emailTextField.text isValidEmail])
    {
        [User setDelegate:self];
        
        [User requestPasswordResetForEmail:emailTextField.text];

    }
}

- (void)requestPasswordResetSuccess
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Petición Raalizada" message:@"Verifique su cuenta de email e ingrese la nueva contraseña" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
