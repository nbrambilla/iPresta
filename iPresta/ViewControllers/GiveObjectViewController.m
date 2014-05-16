//
//  GiveObjectViewController.m
//  iPresta
//
//  Created by Nacho on 27/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "GiveObjectViewController.h"
#import "FriendIP.h"
#import "ObjectIP.h"
#import "GiveIP.h"
#import "DemandIP.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "iPrestaNSString.h"
#import "Facebook.h"
#import "IPTextField.h"
#import "IPButton.h"

@interface GiveObjectViewController ()

@end

@implementation GiveObjectViewController

@synthesize friend = _friend;
@synthesize demand = _demand;

#pragma mark - Lifecycle Methods

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

    if (!_demand)
    {
        UIBarButtonItem *contactsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(goToContacts)];
        self.navigationItem.rightBarButtonItem = contactsButton;
        contactsButton = nil;
    }
    else
    {
        giveToTextField.text = [_demand.from getFullName];
        giveToTextField.enabled = NO;
    }
    [giveButton setTitle:NSLocalizedString(@"Prestar", nil) forState:UIControlStateNormal];
    timeTextField.text = [[GiveIP giveTimesArray] objectAtIndex:0];
    
    if (![UserIP isLinkedToFacebook]) facebookButton.hidden = YES;
    
    // Set Form
    
    form = [EZForm new];
    form.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    form.delegate = self;
    
    EZFormTextField *giveToField = [[EZFormTextField alloc] initWithKey:@"giveTo"];
    giveToField.validationMinCharacters = 1;
    giveToField.inputMaxCharacters = 100;
    
    EZFormRadioField *timeField = [[EZFormRadioField alloc] initWithKey:@"time"];
    [timeField setChoicesFromArray:[GiveIP giveTimesArray]];
    timeField.validationRequiresSelection = YES;
    timeField.validationRestrictedToChoiceValues = YES;
    
    [form addFormField:giveToField];
    [form addFormField:timeField];
    
    [giveToField useTextField:giveToTextField];
    [timeField useTextField:timeTextField];
    
    timeField.inputView = [[UIPickerView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkValidForm
{
    giveButton.enabled = (form.isFormValid) ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [ObjectIP setDelegate:self];
    
    [self checkValidForm];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [ObjectIP setDelegate:nil];
}

- (void)setFriendName:(NSString *)name
{
    giveToTextField.text = name;
}

#pragma mark - People Picker Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    giveToTextField.text = @"";
    _friend = nil;
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (NSInteger j = 0; j < ABMultiValueGetCount(emails); j++)
    {
        NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
        _friend = [FriendIP getWithEmail:email];
        if (_friend) break;
    }
    
    if (firstName) giveToTextField.text = [giveToTextField.text stringByAppendingString:firstName];
    if (middleName) giveToTextField.text = [giveToTextField.text stringByAppendingFormat:@" %@", middleName];
    if (lastName) giveToTextField.text = [giveToTextField.text stringByAppendingFormat:@" %@", lastName];
    
    firstName = nil;
    middleName = nil;
    lastName = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)goToContacts
{
    if ([timeTextField isFirstResponder]) [timeTextField resignFirstResponder];
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Keyboard Methods

- (IBAction)hideKeyboard:(id)sender
{
    for (UIView *subview in [sender subviews])
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            if ([subview isFirstResponder])
            {
                [subview resignFirstResponder];
                break;
            }
        }
    }
}

- (IBAction)giveObject:(id)sender
{
    
    giveToTextField.text = [giveToTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([giveToTextField.text length] > 0)
    {
        [ProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *name = [giveToTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSDate *dateBegin = [NSDate date];
        
        NSInteger time = [timeTextField.text getIntegerTime];
        NSDate *dateEnd = [dateBegin dateByAddingTimeInterval:time];
        
        id to;
        
        if (_friend) to = _friend;
        else if (_demand) to = _demand.from;
        else to = name ;
        
        [[ObjectIP currentObject] giveObjectTo:to from:dateBegin to:dateEnd fromDemand:_demand];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Prestamo otra persona", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)giveObjectSuccess:(GiveIP *)give
{
    if (facebookButton.selected)
    {
        [UserIP shareInFacebook:giveToTextField.text block:^(NSError *error)
        {
            [ProgressHUD hideHUDForView:self.view animated:YES];
            [error manageError];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else [ProgressHUD hideHUDForView:self.view animated:YES];
    
    ObjectIP *currentObject = [ObjectIP currentObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewGivesObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
    
    [self addNotificatioToDate:give.dateEnd object:currentObject.name to:give.name registerId:give.objectId];
    if (!facebookButton.selected) [self.navigationController popViewControllerAnimated:YES];
    if (_demand) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFriendsDemandsTableObserver" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewDemandsObserver" object:nil];
    }
}

- (void)objectError:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    [error manageError];
}

- (IBAction)sharePressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (void)addNotificatioToDate:(NSDate *)date object:(NSString *)object to:(NSString *)name registerId:(NSString *)registerId
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
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

# pragma mark - EZFormDelegate Methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
    [self checkValidForm];
}

@end
