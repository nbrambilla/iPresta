//
//  Language.m
//  iPresta
//
//  Created by Nacho on 16/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Language.h"

static NSBundle *bundle;

@implementation Language

+ (NSString *)get:(NSString *)key alter:(NSString *)alternate {    
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

+ (void)setLanguage:(IdLang)idLang
{
    NSString *path = [[NSBundle mainBundle ] pathForResource:[langShortArray objectAtIndex:idLang] ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:idLang forKey:@"IdLang"];
    [defaults setBool:YES forKey:@"LangIsSet"];
    [defaults synchronize];
}

+ (IdLang)getLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults integerForKey:@"IdLang"];
}

+ (NSString *)getLanguageName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [languagesArray objectAtIndex:[defaults integerForKey:@"IdLang"]];
}

+ (NSString *)getLanguageNameAtindex:(IdLang)idLng
{
    return [languagesArray objectAtIndex:idLng];
}

+ (BOOL)isSet
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults boolForKey:@"LangIsSet"];
}

@end
