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
#import "ObjectsMenuViewController.h"
#import "ProgressHUD.h"
#import "SideMenuViewController.h"
#import "iPrestaNSError.h"
#import "FriendIP.h"

@interface AuthenticateEmailViewController ()

@end

@implementation AuthenticateEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Autenticar email";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *changeEmailButton = [[UIBarButtonItem alloc] initWithTitle:@"Cambiar email" style:UIBarButtonItemStylePlain target:self action:@selector(goToChangeEmail)];
    self.navigationItem.rightBarButtonItem = changeEmailButton;
    
    changeEmailButton = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
}

- (IBAction)resendAuthenticateEmailMassage:(id)sender
{
    [UserIP save];
}

- (void)saveResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];          // Si hay error en el cambio de email
    else [self resendAuthenticateMessageSuccess];   // Si el cambio de email se realiza correctamente
}

- (void)resendAuthenticateMessageSuccess
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mensaje enviado" message:@"Chequee se email y auentique su cuenta" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}

- (IBAction)goToApp:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [UserIP refresh];
}

- (void)refreshResult:(NSError *)error
{
    if (error) // Si hay error en el chequeo
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        [error manageErrorTo:self];
    }
    else [self checkEmailAuthenticationSuccess];    // Si el chequeo se realiza correctamente
}


- (void)checkEmailAuthenticationSuccess
{
    if (![UserIP hasEmailVerified])
    {
        [FriendIP saveAllFriendsFromDBwithBlock:^(NSError *error)
        {
            [ProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error)
            {
                UIViewController *viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
                MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
                [self presentModalViewController:container animated:YES];
                
                viewController = nil;
            }
            else
            {
                [error manageErrorTo:self];
            }
        }];
    }
    else
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        
        NSError *error = [[NSError alloc] initWithCode:NOTAUTHENTICATEDUSER_ERROR userInfo:nil];
        [error manageErrorTo:self];
    }
}

- (void)goToChangeEmail
{
    ChangeEmailViewController *changeEmailViewController = [[ChangeEmailViewController alloc] initWithNibName:@"ChangeEmailViewController" bundle:nil];    
    [self.navigationController pushViewController:changeEmailViewController animated:YES];
    
    changeEmailViewController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
