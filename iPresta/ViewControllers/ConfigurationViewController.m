//
//  ConfigurationViewController.m
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "iPrestaViewController.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "ObjectIP.h"
#import "GiveIP.h"
#import "IPButton.h"
#import "CoreDataManager.h"
#import "AsyncImageView.h"

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)logOut:(id)sender
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [UserIP logOut];
}

- (void)logOutResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];
    else
    {
        [ObjectIP deleteAll];
        [GiveIP deleteAll];
        [CoreDataManager removePersistentStore];
        
        if ([self.presentingViewController isKindOfClass:[iPrestaViewController class]])
        {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)changeVisibility:(UISwitch *)sender
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [UserIP setVisibility:sender.isOn];
    [UserIP save];
}

- (void)saveResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];      // Si hay error al actualizar el usuario
}

- (IBAction)linkWithFacebook:(UISwitch *)sender
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [UserIP linkWithFacebook:sender.isOn];
}

- (void)linkWithFacebookResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageError];      // Si hay error al actualizar el usuario
    else
    {
        __block NSString *message;
        
        if ([UserIP isLinkedToFacebook])
        {
            message = NSLocalizedString(@"Vinculado", nil);
            [self getFacebookInfo];
        }
        else
        {
            message = NSLocalizedString(@"Desvinculado", nil);
            [self removeFacebookInfo];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"Vinculo facebook", nil), message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getFacebookInfo
{
    FBRequest *friendsRequest = [FBRequest requestForMe];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,  NSDictionary* result, NSError *error) {
        
        facebookView.hidden = NO;
        nameLabel.text = [result objectForKey:@"name"];
                
        NSURL *fbImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [result objectForKey:@"id"]]];
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:profileImage];
        profileImage.imageURL = fbImageURL;
    }];
}

- (void)removeFacebookInfo
{
    facebookView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
    self.title = NSLocalizedString(@"Configuracion", nil);
    visibleLabel.text = NSLocalizedString(@"Visible para tus amigos", nil);
    facebookLabel.text = NSLocalizedString(@"Vincular con Facebook", nil);
    [logoutButton setTitle:NSLocalizedString(@"Salir", nil) forState:UIControlStateNormal];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [visibleSwitch setOn:[UserIP visible]];
    [facebookSwitch setOn:[UserIP isLinkedToFacebook]];
    
    if ([UserIP isLinkedToFacebook])
    {
        [self getFacebookInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    visibleLabel = nil;
    logoutButton = nil;
    nameLabel = nil;
    profileImage = nil;
    facebookView = nil;
    [super viewDidUnload];
}
@end
