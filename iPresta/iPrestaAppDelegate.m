//
//  iPrestaAppDelegate.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaObject.h"
#import "User.h"
#import "Give.h"
#import "iPrestaAppDelegate.h"
#import "AuthenticateEmailViewController.h"
#import "iPrestaNavigationController.h"
#import "LoginViewController.h"
#import "ObjectsMenuViewController.h"
#import "iPrestaViewController.h"

@implementation iPrestaAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [User registerSubclass];
    [iPrestaObject registerSubclass];
    [Give registerSubclass];
    [Parse setApplicationId:@"ke5qAMdl1hxNkKPbmJyiOkCqfDkUtvwnRX6PKlXA" clientKey:@"xceoaXQrBv8vRium67iyjZrQfFI8lI0AROGhXsfR"];
    
    // Se carga iPrestaViewController, la pantalla raiz
    
    iPrestaViewController *iprestaViewController = [[iPrestaViewController alloc] initWithNibName:@"iPrestaViewController" bundle:nil];
    
    self.window.rootViewController = iprestaViewController;
    [self.window makeKeyAndVisible];
    
    // Si existe un usuario logueado...
    if ([User currentUser])
    {
        iPrestaNavigationController *navigationController = [[iPrestaNavigationController alloc] initWithNibName:@"iPrestaNavigationController" bundle:nil];
        UIViewController *viewController;
        
        // Si el usuario autentico su email, se redirige a la aplicacion
        if ([User currentUserHasEmailVerified])
        {
            viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
        }
        // Sino, se redirige a la pantalla de autenticacion
        else
        {
            viewController = [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
        }
        
        [navigationController pushViewController:viewController animated:NO];
        [iprestaViewController presentModalViewController:navigationController animated:NO];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
