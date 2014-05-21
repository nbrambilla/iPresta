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
#import "ObjectHistoricGiveViewController.h"
#import "iPrestaNSString.h"
#import "FriendIP.h"
#import "IPButton.h"
#import "AsyncImageView.h"
#import "MMPickerView.h"

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

- (void)setView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    visibleCheckbox.delegate = self;
    ObjectIP *currentObject = [ObjectIP currentObject];
    
    self.title = currentObject.textType;
    
    nameLabel.text = currentObject.name;
    [nameLabel sizeToFit];
    
    authorLabel.text = currentObject.author;
    [authorLabel sizeToFit];
    CGRect frame = authorLabel.frame;
    frame.origin.y = nameLabel.frame.origin.y + nameLabel.frame.size.height + 5.0f;
    authorLabel.frame = frame;
    
    editorialLabel.text = currentObject.editorial;
    [editorialLabel sizeToFit];
    frame = editorialLabel.frame;
    frame.origin.y = authorLabel.frame.origin.y + authorLabel.frame.size.height + 5.0f;
    editorialLabel.frame = frame;
    
    descriptionLabel.text = currentObject.descriptionObject;
    [descriptionLabel sizeToFit];
    frame = descriptionLabel.frame;
    frame.origin.y = editorialLabel.frame.origin.y + editorialLabel.frame.size.height + 5.0f;
    descriptionLabel.frame = frame;
    
    loanUpLabel.text = IPString(@"Prestamo vencido");
    [loanUpLabel sizeToFit];
    frame = loanUpLabel.frame;
    frame.origin.y = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 5.0f;
    loanUpLabel.frame = frame;
    
    frame = stateLabel.frame;
    frame.origin.y = loanUpLabel.frame.origin.y + loanUpLabel.frame.size.height + 5.0f;
    stateLabel.frame = frame;
    
    imageView.image = [UIImage imageNamed:IMAGE_TYPES[currentObject.type.integerValue]];
    if (currentObject.imageURL) imageView.imageURL = [NSURL URLWithString:currentObject.imageURL];
    
    frame = imageView.frame;
    frame.origin.y = stateLabel.frame.origin.y + stateLabel.frame.size.height + 10.0f;
    imageView.frame = frame;
    
    frame = currentUserButtonsView.frame;
    frame.origin.y = imageView.frame.origin.y;
    currentUserButtonsView.frame = frame;
    
    frame = otherUserButtonsView.frame;
    frame.origin.y = imageView.frame.origin.y;
    otherUserButtonsView.frame = frame;
    
    [loanUpButton setTitle:IPString(@"Extender") forState:UIControlStateNormal];
    [giveBackButton setTitle:IPString(@"Devolver") forState:UIControlStateNormal];
    [giveButton setTitle:IPString(@"Prestar") forState:UIControlStateNormal];
    [historycButton setTitle:IPString(@"Historico") forState:UIControlStateNormal];
    [demandButton setTitle:IPString(@"Pedir") forState:UIControlStateNormal];
    visibleLabel.text = IPString(@"Visible");
    
    if (![UserIP objectsUserIsSet] && [UserIP searchUser] == nil)
    {
        currentUserButtonsView.hidden = NO;
        otherUserButtonsView.hidden = YES;
        
        visibleCheckbox.selected = [currentObject.visible boolValue];
        
        [self setGiveView];
    }
    else
    {
        loanUpLabel.hidden = YES;
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
        stateLabel.text = [NSString stringWithFormat:@"%@ %@", IPString(@"Prestado a"), (objectCurrentGive.name) ? objectCurrentGive.name : [objectCurrentGive.to getFullName]];
        
        if ([objectCurrentGive isExpired])
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
        stateLabel.text = @"";
        
        loanUpLabel.hidden = YES;
        loanUpButton.enabled = NO;
        giveButton.enabled = YES;
        giveBackButton.enabled = NO;
    }
}

- (void)checkboxChangeState
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    [[ObjectIP currentObject] setVisibility:visibleCheckbox.selected];
}

- (void)setVisibilitySuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)objectError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [error manageError];      // Si hay error al actualizar el objeto
}

- (IBAction)demand:(id)sender
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    id user = ([UserIP searchUser]) ? [UserIP searchUser] : [UserIP objectsUser];
    
    [[ObjectIP currentObject] demandTo:user];
}

- (void)demandToSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
    [ProgressHUD hideHUDForView:self.view animated:YES];
    demandButton.enabled = NO;
}

- (void)giveError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    [error manageError];      // Si hay error al actualizar el prestamo
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
    [[[UIAlertView alloc] initWithTitle:APP_NAME message:IPString(@"Devolver objecto pregunta") delegate:self cancelButtonTitle:nil otherButtonTitles:IPString(@"Cancelar"), @"OK", nil] show];
}

- (void)giveBackSuccess
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
                  
    [self removeNotificatioWithRegisterId:[[[ObjectIP  currentObject] currentGive] objectId]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewGivesObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewExtendsObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
                  
    [self setGiveView];
}

- (IBAction)goToExtendGive:(id)sender
{
    [MMPickerView showPickerViewInView:self.view withStrings:GIVE_TIMES withOptions:@{MMtextColor: [UIColor blackColor], MMtoolbarColor: [UIColor blackColor], MMbuttonColor: [UIColor whiteColor], MMselectedObject: GIVE_TIMES[0]} completion:^(NSString *selectedString)
    {
        [self extendGive:[selectedString getIntegerTime]];
    }];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewGivesObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewExtendsObserver" object:nil];
    [self addNotificatioToDate:currentGive.dateEnd object:currentGive.name to:currentGive.name registerId:currentGive.objectId];
}

- (void)addNotificatioToDate:(NSDate *)date object:(NSString *)object to:(NSString *)name registerId:(NSString *)registerId
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = date;
    
    localNotification.alertAction = IPString(@"Prestamo vencido");
    localNotification.alertBody = [NSString stringWithFormat:IPString(@"Prestamo vencido push"), object, name];
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

# pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [ProgressHUD  showHUDAddedTo:self.view animated:YES];
        
        ObjectIP  *currentObject = [ObjectIP currentObject];
        [currentObject giveBack];
    }
}

@end
