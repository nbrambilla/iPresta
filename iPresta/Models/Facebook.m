//
//  Facebook.m
//  iPresta
//
//  Created by Nacho on 10/11/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectIP.h"
#import "UserIP.h"
#import "Facebook.h"
#import "iPrestaNSError.h"

#define PERMISIONS @[@"user_about_me", @"publish_stream", @"publish_actions", @"email"]

@implementation Facebook


- (void)login:(void (^)(NSError *))block
{
    
    [PFFacebookUtils logInWithPermissions:PERMISIONS block:^(PFUser *user, NSError *error)
    {
        if (!user) block(error);

        else if (user.isNew)
        {
            // get the user's data from Facebook
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbUser, NSError *error)
            {
                // check and see if a user already exists for this email
                PFQuery *query = [PFUser query];
                [query whereKey:@"username" equalTo:fbUser[@"email"]];
                [query countObjectsInBackgroundWithBlock:^(int number, NSError *error)
                {
                    if(number > 0)
                    {
                        // delete the user that was created as part of Parse's Facebook login
                        [user deleteInBackground];
                        
                        // put the user logged out notification on the wire
                        [[FBSession activeSession] closeAndClearTokenInformation];
                        
                        error = [[NSError alloc] initWithCode:FBLOGINUSEREXISTS_ERROR userInfo:@{@"email":fbUser[@"email"]}];
                        block(error);
                    }
                    else
                    {
                        [user setObject:@YES forKey:@"isFacebookUser"];
                        [user setObject:fbUser[@"email"] forKey:@"username"];
                        
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                        {
                            block(error);
                        }];
                    }
                }];
            }];
        }
        else block(error);
    }];
    
}

- (void)shareText:(NSString *)text block:(void (^)(NSError *))block
{
    NSString *message = [NSString stringWithFormat:IPString(@"Respuesta pedido facebook"), [[ObjectIP currentObject] name], text];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    if ([[ObjectIP currentObject] imageURL])
    {
        [params addEntriesFromDictionary:@{@"picture": [[ObjectIP currentObject] imageURL]}];
    }
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error)
    {
        block(error);
    }];
}

- (void)link:(BOOL)link block:(void (^)(NSError *))block
{
    if (link)
    {
        [PFFacebookUtils linkUser:[UserIP loggedUser] permissions:PERMISIONS block:^(BOOL succeeded, NSError *error)
        {
             [[UserIP loggedUser] setObject:@YES forKey:@"isFacebookUser"];
             [[UserIP loggedUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 block(error);
             }];
        }];
    }
    else
    {
        [PFFacebookUtils unlinkUserInBackground:[UserIP loggedUser] block:^(BOOL succeeded, NSError *error)
         {
             [[UserIP loggedUser] setObject:@NO forKey:@"isFacebookUser"];
             [[UserIP loggedUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 block(error);
             }];
         }];
    }
}

//- (void)shareInFacebook:(NSString *)caption
//{
//    ACAccountStore *accountStore = [ACAccountStore new];
//    
//    // Get the Facebook account type for the access request
//    ACAccountType *fbAccountType = [accountStore
//                                    accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    
//    // Request access to the Facebook account with the access info
//    [accountStore requestAccessToAccountsWithType:fbAccountType
//                                          options:@{ACFacebookAppIdKey: FACEBOOK_APP_ID, ACFacebookPermissionsKey:PERMISIONS, ACFacebookAudienceKey: ACFacebookAudienceEveryone}
//                                       completion:^(BOOL granted, NSError *error) {
//                                           if (granted) {
//                                               // If access granted, then get the Facebook account info
//                                               NSArray *accounts = [accountStore accountsWithAccountType:fbAccountType];
//                                               
//                                               // Get the access token, could be used in other scenarios
//                                               ACAccountCredential *fbCredential = [[accounts lastObject] credential];
//                                               accessToken = [fbCredential oauthToken];
//                                               
//                                               [self postInFacebook:caption];
//                                               // Add code here to make an API request using the SLRequest class
//                                               
//                                           } else {
//                                               NSLog(@"Access not granted");
//                                           }
//                                       }];
//    
//}
//
//- (void)postInFacebook:(NSString *)caption
//{
//    NSString *message = [NSString stringWithFormat:@"Acaba de realizar un prestamo a %@", caption];
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", [[ObjectIP currentObject] name], @"caption", FACEBOOK_APP_ID, ACFacebookAppIdKey, accessToken, @"access_token", nil];
//    
//    if ([[ObjectIP currentObject] imageURL])
//    {
//        [parameters setObject:[[ObjectIP currentObject] imageURL] forKey:@"picture"];
//    }
//    
//    SLRequest *facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
//                                                    requestMethod:SLRequestMethodPOST
//                                                              URL:[NSURL URLWithString:@"https://graph.facebook.com/me/feed/"]
//                                                       parameters:parameters];
//    
//    [facebookRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
//     {
//         if (error) {
//         }
//         else
//         {
//             NSLog(@"Post successful");
//             NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
//             NSLog(@"Response Data: %@", dataString);
//         }
//     }];
//}

@end
