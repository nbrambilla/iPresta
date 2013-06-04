//
//  ExtendGiveViewController.m
//  iPresta
//
//  Created by Nacho on 01/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ExtendGiveViewController.h"
#import "iPrestaObject.h"
#import "Give.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

#define ONE_DAY 60*60*24

@interface ExtendGiveViewController ()

@end

@implementation ExtendGiveViewController

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
    
    giveDetailLabel.text = [NSString stringWithFormat:@"%@ %@", [[iPrestaObject currentObject] name], [[[iPrestaObject currentObject] actualGive] name]];
    
    newToTextView.datePickerMode = STDatePickerModeDateAndTime;
    newToTextView.minimumDate = [[NSDate date] dateByAddingTimeInterval:ONE_DAY];
    newToTextView.date = newToTextView.minimumDate;
    [self stDateText:newToTextView dateChangedTo:newToTextView.minimumDate];
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
    [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    STDateText.text = [dateFormat stringFromDate:date];
    STDateText.date = date;
    
    dateFormat = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)extendGive:(id)sender 
{
    Give *give = [[iPrestaObject currentObject] actualGive];
    give.object = [iPrestaObject currentObject];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    give.dateEnd = [dateFormat dateFromString:newToTextView.text];
    
    [ProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    [give saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [ProgressHUD hideHUDForView:self.view.window animated:YES];
         
         if (error) [error manageErrorTo:self];      // Si error hay al realizar el prestamo
         else                                        // Si el prestamo se realiza correctamente
         {
              give.object.actualGive = give;
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"setObjectViewObserver" object:nil];
              
              [self addNotificatioToDate:give.dateEnd object:give.object.name to:give.name registerId:give.objectId];
              [self.navigationController popViewControllerAnimated:YES];
         }
     }];
    
    dateFormat = nil;
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

- (void)viewDidUnload {
    giveDetailLabel = nil;
    newToTextView = nil;
    [super viewDidUnload];
}
@end
