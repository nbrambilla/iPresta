//
//  FriendIP.m
//  iPresta
//
//  Created by Nacho on 24/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "UserIP.h"
#import "FriendIP.h"
#import "GiveIP.h"
#import "AddressBookRegister.h"

@implementation FriendIP

@dynamic userId;
@dynamic email;
@dynamic firstName;
@dynamic middleName;
@dynamic lastName;
@dynamic give;


+ (void)saveAllFriendsFromDBwithBlock:(void (^)(NSError *))block
{
    NSMutableArray *appContactsArray = [NSMutableArray new];
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    // Se crea un objeto agenda con todos los contactos existentes en el telefono. Se crea un array con la agenda para poder recorrerlo
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSInteger countPeople = ABAddressBookGetPersonCount(addressBook);
    
    
    // se recorre el array de la agenda. Se crean un array de AddressBookRegisters y de emails con toda la agenda
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
            [appContactsArray addObject:reg];
            [emailsArray addObject:email];
        }
        
        [FriendIP save];
    }
    
    // se crea una consulta para poder buscar todos los usuarios de la app de que tenemos en la agenda a partir del array de emails. Se ordena alfabeticamente por emails.
    PFQuery *appUsersQuery = [PFUser query];
    [appUsersQuery whereKey:@"email" containedIn:emailsArray];
    [appUsersQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    [appUsersQuery whereKey:@"emailVerified" equalTo:[NSNumber numberWithBool:YES]];
    [appUsersQuery orderByAscending:@"email"];
    appUsersQuery.limit = 1000;
    
    [appUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
    {
        if (!error) // Si se obtienen los usuarios, se buscan en los registros
        {
            // Se ordenan los registros alfabeticamente a partir del email
            NSArray *sortedAppContactArray = [appContactsArray sortedArrayUsingComparator:^NSComparisonResult(AddressBookRegister *a, AddressBookRegister *b)
                                              {
                                                  NSString *first = a.email;
                                                  NSString *second = b.email;
                                                  return [first compare:second];
                                              }];
            
             int i = 0;
             
             // se buscan las coincidencias en el array de AddressBookRegister para buscar los registros de los usuarios de la app. Si existe el registro del usuario logueado, no se debe mostrar. Al estar ambas listas ordenadas, se mejora el rendimiento de la busqueda
             for (PFUser *user in users)
             {
                 while (![[[sortedAppContactArray objectAtIndex:i] email] isEqual:user.email]) i++;
                 
                 if (![user.email isEqual:[[UserIP loggedUser] email]])
                 {
                     FriendIP *friend = [FriendIP new];
                     friend.email = [[sortedAppContactArray objectAtIndex:i] email];
                     friend.firstName = [[sortedAppContactArray objectAtIndex:i] firstName];
                     friend.middleName = [[sortedAppContactArray objectAtIndex:i] middleName];
                     friend.lastName = [[sortedAppContactArray objectAtIndex:i] lastName];
                 }
             }
             block(nil);
        }
        else
        {
            block(error);
        }
     }];
}

- (NSString *)firstLetter
{
    NSString *compareName = [self getCompareName];
    NSInteger len = [compareName length];
    
    if (len > 1)
    {
        NSString *firstLetter = [[compareName substringWithRange:NSMakeRange(0, 1)] lowercaseString];
        NSString *secondLetter = [[compareName substringWithRange:NSMakeRange(1, 1)] lowercaseString];
        if ([firstLetter isEqual:@"c"] && [secondLetter isEqual:@"h"])
        {
            return @"ch";
        }
        if ([firstLetter isEqual:@"l"] && [secondLetter isEqual:@"l"])
        {
            return @"ll";
        }
        return firstLetter;
    }
    
    return compareName;
}

- (NSString *)getFullName
{
    NSMutableString *name = [NSMutableString new];
    if (self.firstName) [name appendString:self.firstName];
    if (self.middleName) [name appendFormat:@" %@", self.middleName ];
    if (self.lastName) [name appendFormat:@" %@", self.lastName ];
    
    return [name copy];
}

- (NSString *)getCompareName
{
    if (self.lastName) return self.lastName;
    if (self.middleName) return self.middleName;
    return self.firstName;
}

@end
