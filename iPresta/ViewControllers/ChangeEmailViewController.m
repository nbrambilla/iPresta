//
//  ChangeEmailViewController.m
//  iPresta
//
//  Created by Nacho on 27/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "iPrestaNSString.h"

@interface ChangeEmailViewController ()

@end

@implementation ChangeEmailViewController

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
    
    self.title = @"Cambiar email";
    
    changeMailTextLabel.text = [NSString stringWithFormat:@"Su email actual es %@. Si desea cambiarlo, ingrese el nuevo y presione \"Cambiar email\"", [[User currentUser] email]];
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)changeEmail:(id)sender
{
    if ([emailTextField.text isValidEmail])
    {
        [User setDelegate:self];

        [[User currentUser] changeEmail:emailTextField.text];
    }
}

- (void)changeEmailSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email cambiado" message:@"Ahora auntentique el nuevo email y presione Entrar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
