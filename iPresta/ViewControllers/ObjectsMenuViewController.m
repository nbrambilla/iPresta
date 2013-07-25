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
#import "AddressBookRegister.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController)
    {
        [User setObjectsUser:nil];
    }
}

- (void)setView
{    
    self.title = @"Menú";
    
    booksListButton.tag = BookType;
    audioListButton.tag = AudioType;
    videoListButton.tag = VideoType;
    othersListButton.tag = OtherType;
    
    if ([User objectsUserIsSet])
    {
        extrasButtonsView.hidden = YES;
    }
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
    [allObjectsQuery whereKey:@"owner" equalTo:[User objectsUser]];
    
    if ([User objectsUserIsSet])
    {
        [allObjectsQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    }
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    objectCountArray = [[NSMutableArray alloc] initWithObjects:zero, zero, zero, zero, nil];
    
    [allObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        [ProgressHUD hideHUDForView:self.view animated:YES];
         
        if (error)      // Si hay error al obtener los objetos
        {
            [error manageErrorTo:self];
        }
        else            // Si se obtienen los objetos, se cuentan cuantos hay de cada tipo
        {
            for (iPrestaObject *object in objects)
            {
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:object.type], @"type", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
                 
                options = nil;
            }
             
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

- (IBAction)goToObjectsList:(UIButton *)sender
{
    ObjectsListViewController *viewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
    
    [iPrestaObject setTypeSelected:sender.tag];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
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
    
    configButton = nil;
    contactsButton = nil;
    searchButton = nil;
    configLabel = nil;
    contactsLabel = nil;
    searchLabel = nil;
    objectsButtonsView = nil;
    extrasButtonsView = nil;
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

- (IBAction)goToAppContacts:(id)sender
{
    AppContactsListViewController *viewController = [[AppContactsListViewController alloc] initWithNibName:@"AppContactsListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
}

#pragma mark - Search Methods

- (IBAction)searchObject:(id)sender
{
    autoComplete = [[IMOAutocompletionViewController alloc] initWithCancelButton:NO];
    
    [autoComplete setDataSource:self];
    [autoComplete setDelegate:self];
    [autoComplete setTitle:@"Buscar"];
    
    [self.navigationController pushViewController:autoComplete animated:YES];
}

#pragma mark - IMOAutoCompletionViewDataSource Methods;

- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset
{
    NSMutableArray *registersArray = [NSMutableArray new];
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    // Se crea un objeto agenda con todos los contactos existentes en el telefono. Se crea un arrray con la agenda para poder recorrerlo
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSInteger countPeople = ABAddressBookGetPersonCount(addressBook);
        
    // se recorre el array de la agenda. Se crean un arrary de AddressBookRegisters y de emails. Con toda la agenda
    for (NSInteger i = 0; i < countPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *middleName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSInteger countEmails = ABMultiValueGetCount(emails);
        
        for (NSInteger j = 0; j < countEmails; j++)
        {
            NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            
            AddressBookRegister *reg = [[AddressBookRegister alloc] initWithFirstName:firstName middleName:middleName lastName:lastName andEmail:email];
            [registersArray addObject:reg];
            [emailsArray addObject:email];
        }
    }
    
    // se crea una consulata para poder buscar todos los usuarios de la app de que tenemos en la agenda a partir del array de emils.
    PFQuery *appUsersQuery = [User query];
    [appUsersQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    [appUsersQuery whereKey:@"email" containedIn:emailsArray];
    
    [appUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
    {
         if (error) [error manageErrorTo:self];     // Si hay error al obtener los usuarios de la app
         else                                       // Si se obtienen los usuarios, se buscan en los registros
         {
             PFQuery *queryCapitalizedString = [iPrestaObject query];
             [queryCapitalizedString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
             [queryCapitalizedString whereKey:@"owner" containedIn:users];
             [queryCapitalizedString whereKey:@"name" containsString:[param capitalizedString]];
             
             //query converted user text to lowercase
             PFQuery *queryLowerCaseString = [iPrestaObject query];
             [queryLowerCaseString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
             [queryLowerCaseString whereKey:@"owner" containedIn:users];
             [queryLowerCaseString whereKey:@"name" containsString:[param lowercaseString]];
             
             //query real user text
             PFQuery *querySearchBarString = [iPrestaObject query];
             [querySearchBarString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
             [querySearchBarString whereKey:@"owner" containedIn:users];
             [querySearchBarString whereKey:@"name" containsString:param];
             
             PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
            [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (error) [error manageErrorTo:self];     // Si hay error al obtener los usuarios de la app
                else                                       // Si se obtienen los usuarios, se buscan en los registros
                {
                    [autoComplete loadSearchTableWithResults:objects error:error];
                }
            }];
         }
     }];
}

#pragma mark - IMOAutoCompletionViewDelegate Methods;

- (void)IMOAutocompletionViewControllerReturnedCompletion:(id)object
{
    if (object)
    {
//        newObject = (iPrestaObject *)object;
//        [self setFields];
//        [self setNewObject];
    }
}

@end
