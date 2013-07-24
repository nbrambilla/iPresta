//
//  ConfigurationViewController.m
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "iPrestaViewController.h"
#import "User.h"
#import "iPrestaNSError.h"
#import "ProgressHUD.h"

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
    [User logOut];
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
    [[User currentUser] setVisible:sender.isOn];
    
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];      // Si hay error al actualizar el usuario
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [visibleSwitch setOn:[[User currentUser] visible]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
