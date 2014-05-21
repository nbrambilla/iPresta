//
//  iPrestaNSString.m
//  iPresta
//
//  Created by Nacho on 25/04/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSString.h"

#define ONE_DAY 60*60*24

@implementation NSString (iPrestaNSString)

+ (BOOL)areSetUsername:(NSString *)username andPassword:(NSString *)password
{
    BOOL bReturn = ([username length] > 0 && [password length] > 0);
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:IPString(@"Campos vacios") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
    }
    
    return bReturn;
}

- (BOOL)matchWith:(NSString *)confirmPassword
{
    BOOL bReturn = ([self isEqualToString:confirmPassword]);
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:IPString(@"Contraseñas diferentes") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
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
    
    return  bReturn;
}

- (BOOL)isValidBarcode
{
    BOOL bReturn;
    
    NSString *passwordRegex = @"[0-9]{8,15}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    bReturn = [passwordTest evaluateWithObject:self];
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"No es un código de barras" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
        
        bReturn = NO;
    }
    
    return  bReturn;
}

//- (BOOL)isValidPassword
//{
//    BOOL bReturn;
//    
//    NSString *passwordRegex = @"[A-Z0-9a-z]{6,12}";
//    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
//    bReturn = [passwordTest evaluateWithObject:self];
//    
//    if (!bReturn)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"La contraseña debe tener entre 6 y 12 caracteres. Solo podrá contener números o letras" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        
//        alert = nil;
//        
//        bReturn = NO;
//    }
//    
//    return  bReturn;
//}

- (NSString *)formatName
{
    NSData *asciiEncoded = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *accentRemoved = [[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding];
    
    return [[accentRemoved lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

- (NSString *)checkCode
{
    NSString *formatCode = self;
    
    if ([[formatCode substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"])
    {
        formatCode = [formatCode substringWithRange:NSMakeRange(1, [formatCode length] - 1)];
    }
    
    return formatCode;
}

- (NSInteger)getIntegerTime
{
    NSInteger time = 0;
    
    NSString *trimString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray* dividedString = [trimString componentsSeparatedByString:@" "];
    
    NSInteger value = [dividedString[0] integerValue];
    NSString *lapse = dividedString[1];
    
    if ([lapse isEqual:IPString(@"Semana")] || [lapse isEqual:IPString(@"Semanas")]) time = ONE_DAY * 7 * value;
    else if ([lapse isEqual:IPString(@"Mes")] || [lapse isEqual:IPString(@"Meses")]) time = ONE_DAY * 30 * value;
    
    return time;
}

- (NSString *)encodeToURL
{
    NSString *param = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    param = [param stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *paramData = [param dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    param = [[NSString alloc] initWithData:paramData encoding:NSASCIIStringEncoding];
    
    return param;
}

- (NSString *)serialize
{
    return [[self lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

- (NSInteger)distance:(NSString *)string
{
    return [self computeLevenshteinDistanceWithString:string];
}

- (NSInteger)computeLevenshteinDistanceWithString:(NSString *)string
{
    NSInteger *mem; // distance vector
    NSInteger k;
    NSInteger cost, distance;
    
    int selfLength = [self length];
    int stringLength = [string length];
    
    if(selfLength != 0 && stringLength != 0)
    {
        mem = malloc(sizeof(int) * (++selfLength) * (++stringLength));
        
        for(k = 0; k < selfLength; k++) mem[k] = k;
        for(k = 0; k < stringLength; k++ ) mem[k * selfLength] = k;
        
        for(NSInteger i = 1; i < selfLength ; i++)
        {
            for(NSInteger j = 1; j < stringLength; j++)
            {
                if( [self characterAtIndex:i - 1] == [string characterAtIndex:j - 1]) cost = 0;
                else cost = 1;
                
                mem[j * selfLength + i] = MIN(mem[(j - 1) * selfLength + i] + 1, MIN(mem[j * selfLength + i - 1]  + 1, mem[(j - 1) * selfLength + i - 1] + cost));
            }
        }
        distance = mem[selfLength * stringLength - 1];
        free(mem);
        return distance;
    }
    
    return -1; // error
}

@end
