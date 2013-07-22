//
//  ObjectsMenuViewController.m
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectsMenuViewController.h"
#import "ObjectsListViewController.h"
#import "ConfigurationViewController.h"
#import "User.h"
#import "iPrestaObject.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "AppContactsListViewController.h"

@interface ObjectsMenuViewController ()

@end

@implementation ObjectsMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setView];
    [self countObjects];
    [self addObservers];
}

- (void)setView
{    
    self.title = @"Menú";
    
    booksListButton.tag = BookType;
    audioListButton.tag = AudioType;
    videoListButton.tag = VideoType;
    othersListButton.tag = OtherType;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementObjectType:) name:@"IncrementObjectTypeObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementObjectType:) name:@"DecrementObjectTypeObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCountLabels) name:@"SetCountLabelsObserver" object:nil];
}

- (void)countObjects
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *allObjectsQuery = [iPrestaObject query];
    [allObjectsQuery whereKey:@"owner" equalTo:[User currentUser]];
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    objectCountArray = [[NSMutableArray alloc] initWithObjects:zero, zero, zero, zero, nil];
    
    [allObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
         
        if (error)
        {
            [error manageErrorTo:self];
        }         // Si hay error al obtener los objetos
        else                                            // Si se obtienen los objetos, se cuentan cuantos hay de cada tipo
        {
            for (iPrestaObject *object in objects)
            {
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:object.type], @"type", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
                 
                options = nil;
            }
            objects = nil;
             
            [self setCountLabels];
         }
     }];
    
     zero = nil;
}

- (void)setCountLabels
{
    booksLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:0]];
    audioLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:1]];
    videoLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:2]];
    othersLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:3]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToObjectsList:(id)sender
{
    ObjectsListViewController *viewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
    
    UIButton *pressedButton = (UIButton *)sender;
    [iPrestaObject setTypeSelected:pressedButton.tag];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
    pressedButton = nil;
}

- (IBAction)goToConfiguration:(id)sender
{
    ConfigurationViewController *viewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"IncrementObjectTypeObserver"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"DecrementObjectTypeObserver"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"SetCountLabelsObserver"];
    
    booksListButton = nil;
    audioListButton = nil;
    videoListButton = nil;
    othersListButton = nil;
    
    booksLabel = nil;
    audioLabel = nil;
    videoLabel = nil;
    othersLabel = nil;
    
    [super viewDidUnload];
}

- (void)incrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    NSInteger count = [[objectCountArray objectAtIndex:type] integerValue] + 1;
    
    [objectCountArray replaceObjectAtIndex:type withObject:[NSNumber numberWithInteger:count]];
}

- (void)decrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    NSInteger count = [[objectCountArray objectAtIndex:type] integerValue] - 1;
    
    [objectCountArray replaceObjectAtIndex:type withObject:[NSNumber numberWithInteger:count]];
}

#pragma mark - People Picker Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    NSLog(@"%ld", ABAddressBookGetPersonCount(peoplePicker.addressBook));
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
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

- (IBAction)goToAppContacts:(id)sender
{
    AppContactsListViewController *viewController = [[AppContactsListViewController alloc] initWithNibName:@"AppContactsListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
//    ABPeoplePickerNavigationController *peoplePicker = [ABPeoplePickerNavigationController new];
//    peoplePicker.addressBook = [self filteredAddressBook];
//    peoplePicker.peoplePickerDelegate = self;
//    
//    [self presentModalViewController:peoplePicker animated:YES];
}

- (ABAddressBookRef)filteredAddressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSLog(@"%@", ABAddressBookCopyArrayOfAllPeople(addressBook));
    
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *fname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *name;
        NSString *phoneNumber;
        
        if (lname)
        {
            name = [fname stringByAppendingFormat: @" %@", lname];
        } else
        {
            name = fname;
        }
        
        ABMultiValueRef   phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        int count = ABMultiValueGetCount(phoneNumbers);
        
        if (count > 0 && name)
        {
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        }
        
        NSString *firstChar = [[name substringToIndex:1] lowercaseString];
        
        if (![firstChar isEqual:@"a"])
        {
            ABAddressBookRemoveRecord(addressBook, person, nil);
        }
        else
        {
            
        }
    }
    
    return addressBook;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
