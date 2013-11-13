//
//  Twitter.m
//  iPresta
//
//  Created by Nacho on 10/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "Twitter.h"
#import "ObjectIP.h"

@implementation Twitter

- (void)shareInTwitter:(NSString *)caption
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                ACAccount * account = [[accountStore accountsWithAccountType:accountType] lastObject];
                if([account username]==nil){
                    
                } else {
                    
                    NSString *message = [NSString stringWithFormat:@"Acaba de realizar un prestamo a %@ %@", caption, [[ObjectIP currentObject] imageURL]];
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"status" ,nil];
                    
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:parameters];
                    [request setAccount:account];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if(responseData) {
                            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                            if(responseDictionary) {
                                // Probably everything gone fine
                            }
                        } else {
                            // responseDictionary is nil
                        }
                    }];
                }
            }
        }];
    } else {
        
        
    }}

@end
