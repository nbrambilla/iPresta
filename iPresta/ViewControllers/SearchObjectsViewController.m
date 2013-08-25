//
//  SearchObjectsViewController.m
//  iPresta
//
//  Created by Nacho on 15/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SearchObjectsViewController.h"
#import "iPrestaObject.h"
#import "User.h"
#import "UserIP.h"
#import "ObjectDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AddressBookRegister.h"
#import "iPrestaNSError.h"

@interface SearchObjectsViewController ()

@end

@implementation SearchObjectsViewController

- (id)initWithCancelButton:(BOOL)setCancelButton andPagination:(BOOL)setPagination nibName:(NSString *)nibNameOrNil
{
    self = [super initWithCancelButton:setCancelButton andPagination:setPagination nibName:nibNameOrNil];
    if (self)
    {
    
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) [User setSearchUser:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IMOAutoCompletionViewDataSource Methods;

- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param page:(NSInteger)_page offset:(NSInteger)offset
{
    NSArray *registersArray = [self getAddressBookRegisters];
    NSArray *emailsArray = [self getEmailsFromAddressBookRegisters:registersArray];
    
    [self performObjectsSearchWithEmails:emailsArray param:param page:_page andOffset:offset];
}

#pragma mark - IMOAutoCompletionViewDelegate Methods;

- (void)IMOAutocompletionViewControllerReturnedCompletion:(iPrestaObject *)object
{
    if (object)
    {
        ObjectDetailViewController *viewController = [[ObjectDetailViewController alloc] initWithNibName:@"ObjectDetailViewController" bundle:nil];
        
        [iPrestaObject setCurrentObject:object];
        [UserIP setSearchUser:object.owner];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController = nil;
    }
}

- (NSArray *)getAddressBookRegisters
{
    NSMutableArray *registersArray = [NSMutableArray new];
    
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
        }
    }
    return [registersArray copy];
}

- (NSArray *)getEmailsFromAddressBookRegisters:(NSArray *)addressBookRegisters
{
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    for (AddressBookRegister *addressBookRegister in addressBookRegisters)
    {
        [emailsArray addObject:addressBookRegister.email];
    }
    
    return [emailsArray copy];
}

- (void)performObjectsSearchWithEmails:(NSArray *)emailsArray param:(NSString *)param page:(NSInteger)_page andOffset:(NSInteger)offset
{
    // se crea una consulta para poder buscar todos los usuarios de la app de que tenemos en la agenda a partir del array de emails.
    PFQuery *appUsersQuery = [User query];
    [appUsersQuery whereKey:@"email" containedIn:emailsArray];
    [appUsersQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    
    // texto con primeras letras de cada palabra en mayuscula
    PFQuery *queryCapitalizedString = [iPrestaObject query];
    [queryCapitalizedString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    [queryCapitalizedString whereKey:@"owner" matchesQuery:appUsersQuery];
    [queryCapitalizedString whereKey:@"name" containsString:[param capitalizedString]];
    
    // texto en minuscula
    PFQuery *queryLowerCaseString = [iPrestaObject query];
    [queryLowerCaseString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    [queryLowerCaseString whereKey:@"owner" matchesQuery:appUsersQuery];
    [queryLowerCaseString whereKey:@"name" containsString:[param lowercaseString]];
    
    // texto real
    PFQuery *querySearchBarString = [iPrestaObject query];
    [querySearchBarString whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    [querySearchBarString whereKey:@"owner" matchesQuery:appUsersQuery];
    [querySearchBarString whereKey:@"name" containsString:param];
    
    // Combinacion de consultas para poder comparar el parametro con los nombres de los objetos. Subconsulta para poder encontrar los contactos con cuenta en la app.
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
    [finalQuery orderByAscending:@"name"];
    finalQuery.skip = _page * offset;
    finalQuery.limit = offset;
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) [error manageErrorTo:self];     // Si hay error al obtener los objetos de los usuarios amigos de la app
         else                                       // Si se obtienen los objetos, se ordenan los objetos por nombre y se rellena la tabla
         {
             [self loadSearchTableWithResults:objects error:error];
         }
     }];
}

@end
