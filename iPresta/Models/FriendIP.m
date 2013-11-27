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

static NSInteger newFriends;

@dynamic objectId;
@dynamic email;
@dynamic firstName;
@dynamic middleName;
@dynamic lastName;
@dynamic gives;

+ (NSInteger)newFriends
{
    return newFriends;
}

+ (void)getPermissions:(void (^)(BOOL))block
{
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
        
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
        {
            if (granted) block(granted);
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // The user has previously given access, add the contact
        block(YES);
    }
}

+ (void)addFriendsFromDB
{
    [FriendIP getPermissions:^(BOOL granted)
    {
        if (granted)
        {
            NSMutableArray *emailsAddressBookArray = [[FriendIP getEmailsFromAddressBook] mutableCopy];
            NSArray *emailsFriends = [FriendIP getFriendsEmails];
            
            [emailsAddressBookArray removeObjectsInArray:emailsFriends];
            
            PFQuery *friendsQuery = [PFUser query];
            [friendsQuery whereKey:@"email" containedIn:emailsAddressBookArray];
            friendsQuery.limit = 1000;
            
            [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (!error && objects.count > 0)
                {
                    newFriends += objects.count;
                    
                    for (PFUser *friend in objects)
                    {
                        FriendIP *newFriend = [FriendIP new];
                        [newFriend setFriendFrom:friend];
                        [newFriend setDataFromAddressBook];
                        [FriendIP addObject:newFriend];
                    }
                     
                    [FriendIP save];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNewFriendsObserver" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setFriendsObserver" object:nil];
                }
            }];
        }
    }];
}

- (void)setFriendFrom:(PFUser *)friend
{
    self.objectId = friend.objectId;
    self.email = friend.email;
}

- (void)setDataFromAddressBook
{    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSInteger countPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (NSInteger i = 0; i < countPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSInteger countEmails = ABMultiValueGetCount(emails);
        
        for (NSInteger j = 0; j < countEmails; j++)
        {
            NSString *emailAddressBook = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            if ([emailAddressBook isEqual:self.email])
            {
                self.firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                self.middleName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
                self.lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            }
        }
    }
}

+ (NSArray *)getEmailsFromAddressBook
{
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSInteger countPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (NSInteger i = 0; i < countPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSInteger countEmails = ABMultiValueGetCount(emails);
        
        for (NSInteger j = 0; j < countEmails; j++)
        {
            NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            [emailsArray addObject:email];
        }
    }
    return [emailsArray copy];
}

+ (NSArray *)getFriendsEmails
{
    NSArray *allFriends = [FriendIP getAll];
    NSMutableArray *allFriendsEmails = [[NSMutableArray alloc] initWithCapacity:allFriends.count];
    for (FriendIP *friend in allFriends) [allFriendsEmails addObject:friend.email];
    
    return [allFriendsEmails copy];
}

+ (void)saveAllFriendsFromDBwithBlock:(void (^)(NSError *))block
{
    NSMutableArray *appContactsArray = [NSMutableArray new];
    NSMutableArray *emailsArray = [NSMutableArray new];
    
    // Se crea un objeto agenda con todos los contactos existentes en el telefono. Se crea un array con la agenda para poder recorrerlo
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
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
                    friend.objectId = user.objectId;
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

+ (FriendIP *)getWithObjectId:(NSString *)objectId
{
    NSFetchRequest *request = [self fetchRequest];
    [request setEntity:[self entityDescription]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectId = %@", objectId]];

    NSError *error;
    
    NSArray *result = [[[self class] managedObjectContext] executeFetchRequest:request error:&error];
    
    if (result.count > 0) return [result objectAtIndex:0];
    return nil;
}

@end
