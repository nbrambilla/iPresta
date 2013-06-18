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
#import "iPrestaNSString.h"
#import "MLTableAlert.h"

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

    UIBarButtonItem *contactsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(goToContacts)];
    self.navigationItem.rightBarButtonItem = contactsButton;
    
    timeTextField.text = [[Give giveTimesArray] objectAtIndex:0];
    
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
    if ([timeTextField isFirstResponder]) [timeTextField resignFirstResponder];
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)viewDidUnload
{
    giveToTextField = nil;
    timeTextField = nil;
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
    if (textField == timeTextField)
    {
        MLTableAlert *extendGiveTableAlert = [MLTableAlert tableAlertWithTitle:@"Prestar" cancelButtonTitle:@"Cancelar" numberOfRows:^NSInteger (NSInteger section)
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
             timeTextField.text = [[Give giveTimesArray] objectAtIndex:selectedIndex.row];
         } andCompletionBlock:nil];
        
        [extendGiveTableAlert show];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)giveObject:(id)sender
{
    
    giveToTextField.text = [giveToTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([giveToTextField.text length] > 0)
    {
        Give *give = [Give object];
        
        [self setNewGive:give];
        [self saveNewGive:give];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El prestamo de realizarse a otra persona" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
}

- (void)setNewGive:(Give *)give
{
    give.object = [iPrestaObject currentObject];
    
    give.name = [giveToTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    give.dateBegin = [NSDate date];
    
    NSInteger time = [timeTextField.text getIntegerTime];
    give.dateEnd = [give.dateBegin dateByAddingTimeInterval:time ];
    give.actual = YES;
}

- (void)saveNewGive:(Give *)give
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error) [error manageErrorTo:self];      // Si error hay al realizar el prestamo
         else                                        // Si el prestamo se realiza correctamente
         {
             give.object.state = Given;
             
             [give.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  [ProgressHUD hideHUDForView:self.view animated:YES];
                  
                  if (error) [error manageErrorTo:self];      // Si hay error al actualizar el objeto
                  else                                        // Si el objeto se actualiza correctamente
                  {
                      [iPrestaObject setCurrentObject:give.object];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectsTableObserver" object:nil];
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
                      
                      [self addNotificatioToDate:give.dateEnd object:give.object.name to:give.name registerId:give.objectId];
                      [self.navigationController popViewControllerAnimated:YES];
                  }
              }];
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

@end
