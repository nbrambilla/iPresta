//
//  ConfigurationViewController.m
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "LanguageViewController.h"
#import "iPrestaViewController.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"
#import "ObjectIP.h"
#import "GiveIP.h"
#import "CoreDataManager.h"
#import "Language.h"

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
    
    if (error) [error manageErrorTo:self];
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

- (IBAction)goToLanguageView
{
    LanguageViewController *viewController = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
    
    if (error) [error manageErrorTo:self];      // Si hay error al actualizar el usuario
}

- (IBAction)linkWithFacebook:(UISwitch *)sender
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [UserIP linkWithFacebook:sender.isOn];
}

- (void)linkWithFacebookResult:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) [error manageErrorTo:self];      // Si hay error al actualizar el usuario
    else
    {
        __block NSString *message;
        
        if ([UserIP isLinkedToFacebook])
        {
            message = @"vinculado";
            [self getFacebookInfo];
        }
        else
        {
            message = @"desvinculado";
            [self removeFacebookInfo];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Se ha %@ su cuenta de Facebook de forma correcta", message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getFacebookInfo
{
    FBRequest *friendsRequest = [FBRequest requestForMe];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,  NSDictionary* result, NSError *error) {
        
        facebookView.hidden = NO;
        nameLabel.text = [result objectForKey:@"name"];
        
        UIActivityIndicatorView *indicatorImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorImage.frame = profileImage.bounds;
        [indicatorImage setHidesWhenStopped:YES];
        [indicatorImage startAnimating];
        [profileImage addSubview:indicatorImage];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^(void)
                       {
                           NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [result objectForKey:@"id"]]];
                           NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                           [indicatorImage stopAnimating];
                           UIImage* image = [UIImage imageWithData:imageData];
                           if (image)
                           {
                               profileImage.image = image;
                           }
                       });
    }];
}

- (void)removeFacebookInfo
{
    facebookView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
    self.title = [Language get:@"Configuracion" alter:nil];
    visibleLabel.text = [Language get:@"Visible para tus amigos" alter:nil];
    facebookLabel.text = [Language get:@"Vincular con Facebook" alter:nil];
    languageLabel.text = [Language get:@"Idioma" alter:nil];
    [logoutButton setTitle:[Language get:@"Salir" alter:nil] forState:UIControlStateNormal];
    
    [languageButton setTitle:[Language getLanguageName] forState:UIControlStateNormal];
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
    languageButton = nil;
    visibleLabel = nil;
    logoutButton = nil;
    nameLabel = nil;
    profileImage = nil;
    facebookView = nil;
    [super viewDidUnload];
}
@end
