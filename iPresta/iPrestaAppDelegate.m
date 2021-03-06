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
#import "GiveIP.h"
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
    
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
    [PFFacebookUtils initializeFacebook];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Se carga iPrestaViewController, la pantalla raiz
    iPrestaViewController *iprestaViewController = [[iPrestaViewController alloc] initWithNibName:@"iPrestaViewController" bundle:nil];
    
    [self customizeViews];
    
    self.window.rootViewController = iprestaViewController;
    [self.window makeKeyAndVisible];
    
    // Si existe un usuario logueado...
    if ([UserIP loggedUser])
    {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        UIViewController *viewController;
        
        // Si el usuario autentico su email, se redirige a la aplicacion
        if (![UserIP hasEmailVerified] && ![UserIP isFacebookUser:[UserIP loggedUser]])
        {
            navigationController = [[UINavigationController alloc] init];
            viewController = [[AuthenticateEmailViewController alloc] initWithNibName:@"AuthenticateEmailViewController" bundle:nil];
            [navigationController pushViewController:viewController animated:NO];
            [iprestaViewController presentViewController:navigationController animated:NO completion:nil];
        }
        // Sino, se redirige a la pantalla de autenticacion
        else
        {
            viewController = [[ObjectsMenuViewController alloc] initWithNibName:@"ObjectsMenuViewController" bundle:nil];
            navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
            MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
            [iprestaViewController presentViewController:container animated:NO completion:nil];
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
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
    if ([userInfo[@"pushID"] isEqual:@"demand"])
    {
        FriendIP *friend = [FriendIP getByObjectId:userInfo[@"friendId"]];
        ObjectIP *object = [ObjectIP getByObjectId:userInfo[@"objectId"]];
        NSString *demandId = userInfo[@"demandId"];
        
        [object demandFrom:friend withId:demandId];
    }
    else if ([userInfo[@"pushID"] isEqual:@"response"])
    {
        NSString *demandId = userInfo[@"demandId"];
        NSNumber *accepted = userInfo[@"accepted"];
        [DemandIP setState:accepted toDemandWithId:demandId];
    }
    else if ([userInfo[@"pushID"] isEqual:@"give"]) [GiveIP addGivesFromDB];
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
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    if ([UserIP loggedUser])
    {
        [DemandIP refreshStates];
        [DemandIP addDemandsFromDB];
        [GiveIP refreshActuals];
        [GiveIP addGivesFromDB];
        [FriendIP addFriendsFromDB];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshMenuCellsObserver" object:nil];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        if (currentInstallation && currentInstallation.badge != 0)
        {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
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
    if (managedObjectContext != nil) return managedObjectContext;
    
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
    if (managedObjectModel != nil) return managedObjectModel;
    else
    {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        return managedObjectModel;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) return persistentStoreCoordinator;
    
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

- (void)customizeViews
{
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [[UISwitch appearance] setOnTintColor:[UIColor blackColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"black.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, [[UINavigationBar appearance] bounds].size.height)];
    [[[UINavigationBar appearance] layer] setBorderWidth:0.0f];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-SCREEN_WIDTH, 0.0f) forBarMetrics:UIBarMetricsDefault];
}

@end
