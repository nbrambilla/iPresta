//
//  Language.h
//  iPresta
//
//  Created by Nacho on 16/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>

#define languagesArray  @[@"Español", @"English"]
#define langShortArray  @[@"es", @"en"]

typedef enum
{
    Espanol = 0,
    English = 1,
} IdLang;

@interface Language : NSObject

+ (NSString *)get:(NSString *)key alter:(NSString *)alternate;
+ (void)setLanguage:(IdLang)idLang;
+ (IdLang)getLanguage;
+ (NSString *)getLanguageName;
+ (NSString *)getLanguageNameAtindex:(IdLang)idLng;
+ (BOOL)isSet;

@end
