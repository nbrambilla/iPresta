//
//  ObjetosMenuViewController.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjetosMenuViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface ObjetosMenuViewController ()

@end

@implementation ObjetosMenuViewController

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

- (void)errorToSaveUser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error de conexion" message:@"Parece no estar conectado a la red. Intentelo mas tarde." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
