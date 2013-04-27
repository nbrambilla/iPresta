//
//  iPrestaNSString.m
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSString.h"

@implementation NSString (iPrestaNSString)

+ (BOOL)areSetUsername:(NSString *)username andPassword:(NSString *)password
{
    BOOL bReturn = ([username length] > 0 && [password length] > 0);
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Deben completarse el email y la contraseña" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    return bReturn;
}

- (BOOL)isValidEmail
{
    BOOL bReturn;
    
    //BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    //NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSString *emailRegex = stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    bReturn = [emailTest evaluateWithObject:self];
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El email no tiene un formato válido" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        bReturn = NO;
    }
    
    return  bReturn;
}

- (BOOL)isValidPassword
{
    BOOL bReturn;
    
    NSString *passwordRegex = @"[A-Z0-9a-z]{6,12}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    bReturn = [passwordTest evaluateWithObject:self];
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El email debe tener entre 6 y 12 caracteres. Solo podrá contener números o letras" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        bReturn = NO;
    }
    
    return  bReturn;
}

@end
