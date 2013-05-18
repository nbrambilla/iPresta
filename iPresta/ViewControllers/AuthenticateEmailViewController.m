//
//  AuthenticateEmailViewController.m
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "AuthenticateEmailViewController.h"
#import "iPrestaNSString.h"
#import "ChangeEmailViewController.h"
#import "ObjectsListViewController.h"
#import "iPrestaNavigationController.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "User.h"

@interface AuthenticateEmailViewController ()

@end

@implementation AuthenticateEmailViewController

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
    
    self.title = @"Autenticar email";
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *changeEmailButton = [[UIBarButtonItem alloc] initWithTitle:@"Cambiar email" style:UIBarButtonItemStylePlain target:self action:@selector(goToChangeEmail)];
    self.navigationItem.rightBarButtonItem = changeEmailButton;
    
    changeEmailButton = nil;
}

- (IBAction)resendAuthenticateEmailMassage:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    //[[PFUser currentUser] setEmail:self.email];
        
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view.window animated:YES];
        
        if (error) [error manageErrorTo:self];          // Si hay error en el cambio de email
        else [self resendAuthenticateMessageSuccess];   // Si el cambio de email se realiza correctamente
    }];
}

- (void)resendAuthenticateMessageSuccess
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mensaje enviado" message:@"Chequee se email y auentique su cuenta" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}

- (IBAction)goToApp:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view.window animated:YES];
        
        if (error) [error manageErrorTo:self];          // Si hay error en el cambio de email
        else [self checkEmailAuthenticationSuccess];    // Si el cambio de email se realiza correctamente
    }];
}

- (void)checkEmailAuthenticationSuccess
{
    if ([User currentUserHasEmailVerified])
    {
        UINavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        UITableViewController *tableViewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
        [navigationController pushViewController:tableViewController animated:NO];
        
        [self presentModalViewController:navigationController animated:YES];
        
        navigationController = nil;
        tableViewController = nil;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"El email no esta autenticado" message:@"Debe autenticar su email para poder acceder a la app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)goToChangeEmail
{
    ChangeEmailViewController *changeEmailViewController = [[ChangeEmailViewController alloc] initWithNibName:@"ChangeEmailViewController" bundle:nil];    
    [self.navigationController pushViewController:changeEmailViewController animated:YES];
    
    changeEmailViewController = nil;
}

- (void)viewDidUnload
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
