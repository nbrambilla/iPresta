//
//  ObjectDetailViewController.m
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "GiveObjectViewController.h"
#import "iPrestaObject.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "Give.h"
#import "User.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setView) name:@"setObjectViewObserver" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController)
    {
        [iPrestaObject setCurrentObject:nil];
        [User setSearchUser:nil];
    }
    
    [super viewWillDisappear:animated];
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
    [super viewDidUnload];
}

- (void)setView
{
    typeLabel.text = [[iPrestaObject currentObject] textType];
    nameLabel.text = [[iPrestaObject currentObject] name];
    authorLabel.text = [[iPrestaObject currentObject] author];
    editorialLabel.text = [[iPrestaObject currentObject] editorial];
    descriptionLabel.text = [[iPrestaObject currentObject] descriptionObject];
    imageView.image = [UIImage imageWithData:[[iPrestaObject currentObject] imageData]];
    loanUpLabel.hidden = YES;
    
    if (![User objectsUserIsSet] && [User searchUser] == nil)
    {
        currentUserButtonsView.hidden = NO;
        otherUserButtonsView.hidden = YES;
        
        [visibleSwitch setOn:[[iPrestaObject currentObject] visible]];
        
        if ([[iPrestaObject currentObject] state] == Given)
        {
            giveButton.enabled = NO;
            giveBackButton.enabled = YES;
            
            PFQuery *getActualGiveQuery = [Give query];
            [getActualGiveQuery whereKey:@"object" equalTo:[iPrestaObject currentObject]];
            [getActualGiveQuery whereKey:@"actual" equalTo:[NSNumber numberWithBool:YES]];
            
            [ProgressHUD  showHUDAddedTo:self.view animated:YES];
            
            [getActualGiveQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
                [ProgressHUD hideHUDForView:self.view animated:YES];
                
                [[iPrestaObject currentObject] setActualGive:(Give *)object];
                stateLabel.text = [NSString stringWithFormat:@"%@ a %@", [[iPrestaObject currentObject] textState], [[[iPrestaObject currentObject] actualGive] name]];
                
                if ([[[[iPrestaObject currentObject] actualGive] dateEnd] compare:[NSDate date]] == NSOrderedAscending)
                {
                    loanUpLabel.hidden = NO;
                    loanUpButton.enabled = YES;
                }
                else
                {
                    loanUpLabel.hidden = YES;
                    loanUpButton.enabled = NO;
                }
            }];
        }
        else
        {
            stateLabel.text = [[iPrestaObject currentObject] textState];
            
            loanUpButton.enabled = NO;
            giveButton.enabled = YES;
            giveBackButton.enabled = NO;
        }
    }
    else
    {
        currentUserButtonsView.hidden = YES;
        otherUserButtonsView.hidden = NO;
    }
}

- (IBAction)changeVisibility:(UISwitch *)sender
{
    iPrestaObject *currentObject = [iPrestaObject currentObject];
    currentObject.visible = sender.isOn;
    
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) [error manageErrorTo:self];      // Si hay error al actualizar el objeto
    }];
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
    iPrestaObject *currentObject = [iPrestaObject currentObject];
    currentObject.state = Property;
    
    [ProgressHUD  showHUDAddedTo:self.view animated:YES];
    
    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         if (error) [error manageErrorTo:self];      // Si hay error al actualizar el objeto
         else                                        // Si el objeto se actualiza correctamente
         {
             currentObject.actualGive.actual = NO;
             currentObject.actualGive.dateEnd = [NSDate date];
             
             [currentObject.actualGive saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 [ProgressHUD hideHUDForView:self.view animated:YES];
                 
                 [iPrestaObject setCurrentObject:currentObject];
                 [self removeNotificatioWithRegisterId:[[[iPrestaObject currentObject] actualGive] objectId]];
                 
                 currentObject.actualGive = nil;
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
                 
                 [self setView];
             }];
         }
     }];
}

- (IBAction)goToExtendGive:(id)sender
{
	MLTableAlert *extendGiveTableAlert = [MLTableAlert tableAlertWithTitle:@"Extender préstamo" cancelButtonTitle:@"Cancelar" numberOfRows:^NSInteger (NSInteger section)
        {
            return [[Give giveTimesArray] count];
        }
            andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
        {
          static NSString *CellIdentifier = @"CellIdentifier";
          UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
          if (cell == nil)
              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
          
          cell.textLabel.text = [[Give giveTimesArray] objectAtIndex:indexPath.row];
          
          return cell;
        }];
	
	extendGiveTableAlert.height = 250;
	
	[extendGiveTableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex)
    {
         [self extendGive:[[[Give giveTimesArray] objectAtIndex:selectedIndex.row] getIntegerTime]];
	} andCompletionBlock:nil];
	
	[extendGiveTableAlert show];
}

- (void)extendGive:(NSInteger)time
{
    Give *give = [[iPrestaObject currentObject] actualGive];
    give.object = [iPrestaObject currentObject];
    
    give.dateEnd = [[NSDate date] dateByAddingTimeInterval:time];
    
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];      // Si error hay al realizar el prestamo
         else                                        // Si el prestamo se realiza correctamente
         {
             give.object.actualGive = give;
             
             [self setView];
             [self addNotificatioToDate:give.dateEnd object:give.object.name to:give.name registerId:give.objectId];
         }
     }];
}

- (void)addNotificatioToDate:(NSDate *)date object:(NSString *)object to:(NSString *)name registerId:(NSString *)registerId
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    
    localNotification.alertAction = @"Prestamo Vencido";
    localNotification.alertBody = [NSString stringWithFormat:@"Ha vencido el prestamo de \"%@\" a %@", object, name];
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
