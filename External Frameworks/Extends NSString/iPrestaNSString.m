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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Deben completarse el email y la contraseña" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Las contraseñas son diferentes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    if (!bReturn)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"El email no tiene un formato válido" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"La contraseña debe tener entre 6 y 12 caracteres. Solo podrá contener números o letras" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        alert = nil;
        
        bReturn = NO;
    }
    
    return  bReturn;
}

- (NSString *)formatName
{
    NSData *asciiEncoded = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *accentRemoved = [[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding];
    
    return [[accentRemoved lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

- (NSString *)formatCode
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
    NSArray* dividedString = [trimString componentsSeparatedByString: @" "];
    
    NSInteger value = [[dividedString objectAtIndex:0] integerValue];
    NSString *lapse = [[dividedString objectAtIndex:1] lowercaseString];
    
    if ([lapse isEqual:@"día"] || [lapse isEqual:@"días"])
    {
        time = ONE_DAY * value;
    }
    else if ([lapse isEqual:@"semana"] || [lapse isEqual:@"semanas"])
    {
        time = ONE_DAY * 7 * value;
    }
    else if ([lapse isEqual:@"mes"] || [lapse isEqual:@"meses"])
    {
        time = ONE_DAY * 30 * value;
    }
    
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

- (int)computeLevenshteinDistanceWithString:(NSString *) string
{
    int *d; // distance vector
    int i,j,k; // indexes
    int cost, distance;
    
    int n = [self length];
    int m = [string length];
    
    if( n!=0 && m!=0 ){
        
        d = malloc( sizeof(int) * (++n) * (++m) );
        
        for( k=0 ; k<n ; k++ )
            d[k] = k;
        for( k=0 ; k<m ; k++ )
            d[k*n] = k;
        
        for( i=1; i<n ; i++ ) {
            for( j=1 ;j<m ; j++ ) {
                if( [self characterAtIndex:i-1] == [string characterAtIndex:j-1])
                    cost = 0;
                else
                    cost = 1;
                d[j*n+i]=minimum(d[(j-1)*n+i]+1,d[j*n+i-1]+1,d[(j-1)*n+i-1]+cost);
            }
        }
        distance = d[n*m-1];
        free(d);
        return distance;
    }
    
    return -1; // error
}

int minimum(int a,int b,int c)
{
    int min=a;
    if(b<min)
        min=b;
    if(c<min)
        min=c;
    return min;
}

@end
