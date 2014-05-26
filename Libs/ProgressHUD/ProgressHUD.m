//
//  ProgressHUD.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ProgressHUD.h"

@implementation ProgressHUD

+ (void)showProgressHUDIn:(id)delegate
{
    UIViewController *viewController = (UIViewController *)delegate;
    [PF_MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    viewController = nil;
}

+ (void)hideProgressHUDIn:(id)delegate
{
    UIViewController *viewController = (UIViewController *)delegate;
    [PF_MBProgressHUD hideHUDForView:viewController.view animated:YES];
    
    viewController = nil;
}

@end
