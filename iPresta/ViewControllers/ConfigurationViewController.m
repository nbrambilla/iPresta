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
#import "CoreDataManager.h"

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Configuración";
    }
    return self;
}

- (IBAction)logOut:(id)sender
{
    [ObjectIP deleteAll];
    [GiveIP deleteAll];
    [CoreDataManager removePersistentStore];
    
    [UserIP logOut];
    
    if ([self.presentingViewController isKindOfClass:[iPrestaViewController class]])
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    
    if (error) [error manageErrorTo:self];      // Si hay error al actualizar el usuario
}

- (void)viewDidAppear:(BOOL)animated
{
    [UserIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UserIP setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [visibleSwitch setOn:[UserIP visible]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
