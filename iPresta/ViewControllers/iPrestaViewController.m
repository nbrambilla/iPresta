//
//  iPrestaViewController.m
//  iPresta
//
//  Created by Nacho on 20/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaViewController.h"
#import "LoginViewController.h"
#import "CreateCountViewController.h"
#import "Language.h"

@interface iPrestaViewController ()

@end

@implementation iPrestaViewController

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
    
    if (![Language isSet]) {
        languageView.frame = self.view.frame;
        [self.view addSubview:languageView];
    }
    else [self setTexts];
}

- (void)setTexts
{
    [haveCountButton setTitle:[Language get:@"Tengo una cuenta" alter:nil] forState:UIControlStateNormal];
    [createCountButton setTitle:[Language get:@"Crear una cuenta" alter:nil] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToLogIn:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [navigationController pushViewController:loginViewController animated:NO];
    
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)goToCreateCount:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    CreateCountViewController *createCountViewController = [[CreateCountViewController alloc] initWithNibName:@"CreateCountViewController" bundle:nil];
    [navigationController pushViewController:createCountViewController animated:NO];
    
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)setLanguage:(UIButton *)sender
{
    [Language setLanguage:sender.tag];
    [languageView removeFromSuperview];
    [self setTexts];
}

- (void)viewDidUnload {
    languageView = nil;
    [super viewDidUnload];
}
@end
