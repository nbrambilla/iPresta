//
//  iPrestaAppDelegate.m
//  iPresta
//
//  Created by Nacho on 15/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "UserIP.h"
#import "ObjectIP.h"
#import "FriendIP.h"
#import "DemandIP.h"
#import "iPrestaAppDelegate.h"
#import "AuthenticateEmailViewController.h"
#import "LoginViewController.h"
#import "ObjectsMenuViewController.h"
#import "iPrestaViewController.h"
#import "SideMenuViewController.h"

@implementation iPrestaAppDelegate

@synthesize window;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Parse setApplicationId:@"ke5qAMdl1hxNkKPbmJyiOkCqfDkUtvwnRX6PKlXA" clientKey:@"xceoaXQrBv8vRium67iyjZrQfFI8lI0AROGhXsfR"];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    // Se carga iPrestaViewController, la pantalla raiz
    
    iPrestaViewController *iprestaViewController = [[iPrestaViewController alloc] initWithNibName:@"iPrestaViewController" bundle:nil];
    
    self.window.rootViewController = iprestaViewController;
    [self.window makeKeyAndVisible];
    
    // Si existe un usuario logueado...
    if ([UserIP loggedUser])
    {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        UIViewController *viewController;
        
        // Si el usuario autentico su email, se redirige a la aplicacion
        if ([UserIP hasEmailVerified])
        {
            viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
            navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
            MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
            [iprestaViewController presentModalViewController:container animated:NO];
        }
        // Sino, se redirige a la pantalla de autenticacion
        else
        {
            navigationController = [[UINavigationController alloc] init];
            viewController = [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
            [navigationController pushViewController:viewController animated:NO];
            [iprestaViewController presentModalViewController:navigationController animated:NO];
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [PFPush storeDeviceToken:deviceToken];
    [PFPush subscribeToChannelInBackground:@""];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to register remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // No entra si la app no esta activa o en background. Ver para resolver en estos casos
    [PFPush handlePush:userInfo];
    
    FriendIP *friend = [FriendIP getByObjectId:[userInfo objectForKey:@"friendId"]];
    ObjectIP *object = [ObjectIP getByObjectId:[userInfo objectForKey:@"objectId"]];
    
    [object demandFrom:friend];
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
    [DemandIP addtDemandsFromDB];
    [FriendIP addFriendsFromDB];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation && currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error = nil;
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    else
    {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        return managedObjectModel;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"iPresta.sqlite"]];
    
    NSError *error = nil;
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (void)removeCoreDataContext
{
    managedObjectContext = nil;
    managedObjectModel = nil;
    persistentStoreCoordinator = nil;
    
    // Delete the sqlite file
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"iPresta.sqlite"])
    {
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"iPresta.sqlite"]];
        if ([[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
