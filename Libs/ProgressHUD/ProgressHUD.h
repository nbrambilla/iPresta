//
//  ProgressHUD.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/PF_MBProgressHUD.h>

@interface ProgressHUD : PF_MBProgressHUD

+ (void)showProgressHUDIn:(id)delegate;
+ (void)hideProgressHUDIn:(id)delegate;

@end
