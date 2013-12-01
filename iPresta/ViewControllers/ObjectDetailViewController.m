//
//  ObjectDetailViewController.m
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "GiveObjectViewController.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "MLTableAlert.h"
#import "ObjectHistoricGiveViewController.h"
#import "iPrestaNSString.h"


@interface ObjectDetailViewController ()

@end

@implementation ObjectDetailViewController

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
    [self setView];
    [self addObservers];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setGiveView) name:@"setObjectViewObserver" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [ObjectIP setDelegate:self];
    [GiveIP setDelegate:self];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController)
    {
        [ObjectIP setDelegate:nil];
        [GiveIP setDelegate:nil];
        
        [ObjectIP setCurrentObject:nil];
        [UserIP setSearchUser:nil];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"setObjectViewObserver"];
    
    typeLabel = nil;
    nameLabel = nil;
    authorLabel = nil;
    editorialLabel = nil;
    stateLabel = nil;
    descriptionLabel = nil;
    giveButton = nil;
    giveBackButton = nil;
    loanUpLabel = nil;
    loanUpButton = nil;
    historycButton = nil;
    visibleSwitch = nil;
    currentUserButtonsView = nil;
    otherUserButtonsView = nil;
    demandButton = nil;
    [super viewDidUnload];
}

- (void)setView
{
    ObjectIP *currentObject = [ObjectIP currentObject];
    
    typeLabel.text = currentObject.textType;
    nameLabel.text = currentObject.name;
    authorLabel.text = currentObject.author;
    editorialLabel.text = currentObject.editorial;
    descriptionLabel.text = currentObject.descriptionObject;
    imageView.image = [UIImage imageWithData:currentObject.image];
    loanUpLabel.hidden = YES;
    
    [loanUpButton setTitle:NSLocalizedString(@"Extender", nil) forState:UIControlStateNormal];
    [giveBackButton setTitle:NSLocalizedString(@"Devolver", nil) forState:UIControlStateNormal];
    [giveButton setTitle:NSLocalizedString(@"Prestar", nil) forState:UIControlStateNormal];
    [historycButton setTitle:NSLocalizedString(@"Historico", nil) forState:UIControlStateNormal];
    [demandButton setTitle:NSLocalizedString(@"Pedir", nil) forState:UIControlStateNormal];
    
    if (![UserIP objectsUserIsSet] && [UserIP searchUser] == nil)
    {
        currentUserButtonsView.hidden = NO;
        otherUserButtonsView.hidden = YES;
        
        [visibleSwitch setOn:[currentObject.visible boolValue]];
        
        [self setGiveView];
    }
    else
    {
        currentUserButtonsView.hidden = YES;
        otherUserButtonsView.hidden = NO;
    }
}

- (void)setGiveView
{
    ObjectIP  *currentObject = [ObjectIP  currentObject];
    
    if ([currentObject.state integerValue] == Given)
    {
        giveButton.enabled = NO;
        giveBackButton.enabled = YES;
        
        GiveIP *objectCurrentGive = [currentObject currentGive];
        stateLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Prestado a", nil), [objectCurrentGive name]];
        
        if ([[objectCurrentGive dateEnd] compare:[NSDate date]] == NSOrderedAscending)
        {
            loanUpLabel.hidden = NO;
            loanUpButton.enabled = YES;
        }
        else
        {
            loanUpLabel.hidden = YES;
            loanUpButton.enabled = NO;
        }
    }
    else
    {
        stateLabel.text = [currentObject textState];
        
        loanUpButton.enabled = NO;
        giveButton.enabled = YES;
        giveBackButton.enabled = NO;
    }
}

- (IBAction)changeVisibility:(UISwitch *)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [[ObjectIP currentObject] setVisibility:sender.isOn];
}

- (void)setVisibilitySuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)objectError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [error manageErrorTo:self];      // Si hay error al actualizar el objeto
}

- (IBAction)demand:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    id user = ([UserIP searchUser]) ? [UserIP searchUser] : [UserIP objectsUser];
    
    [[ObjectIP currentObject] demandTo:user];
}

- (void)demandToSuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    demandButton.enabled = NO;
}

- (void)giveError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [error manageErrorTo:self];      // Si hay error al actualizar el prestamo
}

- (IBAction)goToGiveObject:(id)sender
{
    GiveObjectViewController *viewController = [[GiveObjectViewController alloc] initWithNibName:@"GiveObjectViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];

    viewController = nil;
}
- (IBAction)goToObjectHistoricGives:(id)sender
{
    ObjectHistoricGiveViewController *viewController = [[ObjectHistoricGiveViewController alloc] initWithNibName:@"ObjectHistoricGiveViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
}

- (IBAction)giveBackObject:(id)sender
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    ObjectIP  *currentObject = [ObjectIP currentObject];
    [currentObject giveBack];
}

- (void)giveBackSuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
                  
    [self removeNotificatioWithRegisterId:[[[ObjectIP  currentObject] currentGive] objectId]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
                  
    [self setGiveView];
}

- (IBAction)goToExtendGive:(id)sender
{
	MLTableAlert *extendGiveTableAlert = [MLTableAlert tableAlertWithTitle:NSLocalizedString(@"Extender prestamo", nil) cancelButtonTitle:NSLocalizedString(@"Cancelar", nil) numberOfRows:^NSInteger (NSInteger section)
        {
            return [[GiveIP giveTimesArray] count];
        }
            andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
        {
          static NSString *CellIdentifier = @"CellIdentifier";
          UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
          if (cell == nil)
              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
          
          cell.textLabel.text = [[GiveIP giveTimesArray] objectAtIndex:indexPath.row];
          
          return cell;
        }];
	
	extendGiveTableAlert.height = 250;
	
	[extendGiveTableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex)
    {
         [self extendGive:[[[GiveIP giveTimesArray] objectAtIndex:selectedIndex.row] getIntegerTime]];
	} andCompletionBlock:nil];
	
	[extendGiveTableAlert show];
}

- (void)extendGive:(NSInteger)time
{
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    GiveIP *give = [[ObjectIP currentObject] currentGive];
    [give extendGive:time];
    
}

- (void)extendGiveSuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [self setGiveView];
    
    GiveIP *currentGive = [[ObjectIP currentObject] currentGive];
    [self addNotificatioToDate:currentGive.dateEnd object:currentGive.name to:currentGive.name registerId:currentGive.objectId];
}

- (void)addNotificatioToDate:(NSDate *)date object:(NSString *)object to:(NSString *)name registerId:(NSString *)registerId
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = date;
    
    localNotification.alertAction = NSLocalizedString(@"Prestamo vencido", nil);
    localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Prestamo vencido push", nil), object, name];
    localNotification.hasAction = YES;
    //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:registerId, @"id", nil];
    localNotification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    userInfo = nil;
}

- (void)removeNotificatioWithRegisterId:(NSString *)registerId
{
    NSArray *notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotification in notificationsArray)
    {
        NSDictionary *userInfoCurrent = localNotification.userInfo;
        NSString *id = [NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"id"]];
        if ([id isEqualToString:registerId])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            break;
        }
    }
    
    notificationsArray = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
