//
//  SearchObjectsViewController.m
//  iPresta
//
//  Created by Nacho on 15/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "SearchObjectsViewController.h"
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
    objects = [NSMutableArray new];
    owners = [NSMutableArray new];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [ObjectIP setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ObjectIP setDelegate:nil];
    if (self.isMovingFromParentViewController) [UserIP setSearchUser:nil];
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
    
    [ObjectIP performObjectsSearchWithEmails:emailsArray param:param page:_page andOffset:offset];
}

- (void)performObjectsSearchSuccess:(NSDictionary *)params error:(NSError *)error
{
    [objects addObjectsFromArray:[params objectForKey:@"objects"]];
    [owners addObjectsFromArray:[params objectForKey:@"owners"]];
    
    [self loadSearchTableWithResults:[params objectForKey:@"objects"] error:error];
}

#pragma mark - IMOAutoCompletionViewDelegate Methods;

- (void)IMOAutocompletionViewControllerReturnedCompletion:(ObjectIP *)object
{
    if (object)
    {
        ObjectDetailViewController *viewController = [[ObjectDetailViewController alloc] initWithNibName:@"ObjectDetailViewController" bundle:nil];
        
        [ObjectIP setCurrentObject:object];
        NSUInteger index = [objects indexOfObject:object];
        [UserIP setSearchUser:[owners objectAtIndex:index]];
        
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

@end
