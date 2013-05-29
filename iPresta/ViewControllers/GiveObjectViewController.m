//
//  GiveObjectViewController.m
//  iPresta
//
//  Created by Nacho on 27/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//


#import "GiveObjectViewController.h"
#import "iPrestaObject.h"
#import "Give.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@interface GiveObjectViewController ()

@end

@implementation GiveObjectViewController

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

    UIBarButtonItem *contactsButton = [[UIBarButtonItem alloc] initWithTitle:@"Contactos" style:UIBarButtonItemStyleBordered target:self action:@selector(goToContacts)];
    self.navigationItem.rightBarButtonItem = contactsButton;
    
    fromTextView.datePickerMode = STDatePickerModeDateAndTime;
    toTextField.datePickerMode = STDatePickerModeDateAndTime;
    
    contactsButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    giveToTextField.text = @"";
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    if (firstName) giveToTextField.text = [giveToTextField.text stringByAppendingString:firstName];
    if (middleName) giveToTextField.text = [giveToTextField.text stringByAppendingFormat:@" %@", middleName];
    if (lastName) giveToTextField.text = [giveToTextField.text stringByAppendingFormat:@" %@", lastName];
    
    firstName = nil;
    middleName = nil;
    lastName = nil;
    
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)goToContacts
{
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)viewDidUnload
{
    giveToTextField = nil;
    fromTextView = nil;
    toTextField = nil;
    [super viewDidUnload];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isKindOfClass:[STDateText class]])
    {
        STDateText *dateText = (STDateText*)textField;
        [dateText showDatePicker];
        
        return NO;
    }
    return YES;
}

- (void)stDateText:(STDateText*)STDateText dateChangedTo:(NSDate*)date
{
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
     [STDateText setText:[dateFormat stringFromDate:date]];
}

- (IBAction)giveObject:(id)sender
{
    Give *give = [Give object];
    
    give.object = [iPrestaObject currentObject];
    
    give.name = giveToTextField.text;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
    give.dataBegin = [dateFormat dateFromString:fromTextView.text];
    
    give.dataEnd = [dateFormat dateFromString:toTextField.text];
    
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error) [error manageErrorTo:self];      // Si error hay al realizar el prestamo
        else                                        // Si el prestamo se realiza correctamente
        {
            give.object.state = Given;
            
            [give.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                [ProgressHUD hideHUDForView:self.view.window animated:YES];
                
                if (error) [error manageErrorTo:self];      // Si hay error al actualizar el objeto
                else                                        // Si el objeto se actualiza correctamente
                {
                    [iPrestaObject setCurrentObject:give.object];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
                    
                    [self addNotificatioToDate:give.dataEnd object:give.object.name to:give.name];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];
    
    dateFormat = nil;
}

- (void)addNotificatioToDate:(NSDate *)date object:(NSString *)object to:(NSString *)name
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    [localNotification setFireDate:date];
    
    [localNotification setAlertAction:@"Prestamo Vencido"];
    [localNotification setAlertBody:[NSString stringWithFormat:@"Ha vencido el prestamo de %@ a %@", object, name]];
    [localNotification setHasAction: YES];
    [localNotification setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
