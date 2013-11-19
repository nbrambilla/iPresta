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

#define FACEBOOK_APP_ID @"436412689778314"
#define PERMISIONS @[@"user_about_me", @"publish_stream", @"publish_actions", @"email"]

@implementation Facebook

+ (void)activateSession:(void (^)(NSError *))block
{
    if (!FBSession.activeSession.isOpen)
    {
        [FBSession openActiveSessionWithPublishPermissions:PERMISIONS
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             if (!error && state == FBSessionStateOpen) {
                                                 block(nil);
                                             } else {
                                                 block(error);
                                             }
                                         }];
    }
    else block(nil);
}

- (void)login:(void (^)(NSError *))block
{
    [Facebook activateSession:^(NSError *error) {
        if (!error) {
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
             {
                 if (!error) {
                     PFQuery *userQuery = [PFUser query];
                     [userQuery whereKey:@"email" equalTo:[user objectForKey:@"email"]];
                     [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                         if (!error)
                         {
                             PFUser *user= (PFUser *)object;
                             
                             if (user)
                             {
                                 if (![UserIP isFacebookUser:user]) {
                                     error = [[NSError alloc] initWithCode:FBLOGINUSEREXISTS_ERROR userInfo:@{@"email":[user objectForKey:@"email"]}];
                                     block(error);
                                 }
                                 else
                                 {
                                     [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error)
                                      {
                                          [user setObject:[NSNumber numberWithBool:YES] forKey:@"isFacebookUser"];
                                          
                                          [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                              block(error);
                                          }];
                                      }];
                                 }
                             }
                             else
                             {
                                 [PFFacebookUtils logInWithPermissions:PERMISIONS block:^(PFUser *user, NSError *error)
                                 {
                                      block(error);
                                 }];
                             }
                         }
                         else block(error);
                     }];
                 }
                 else
                 {
                     error = [[NSError alloc] initWithCode:FBLOGIN_ERROR userInfo:nil];
                     block(error);
                 }
             }];
        }
        else block(error);
    }];
}

- (void)shareText:(NSString *)text inContainer:(UIViewController *)container
{    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result)
    {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [container.navigationController popViewControllerAnimated:YES];
    };
    
    controller.completionHandler = myBlock;
    
    NSString *message = [NSString stringWithFormat:@"Acaba de prestar \"%@\" a %@", [[ObjectIP currentObject] name], text];
    
    if ([[ObjectIP currentObject] image])
    {
        UIImage *objectImage = [UIImage imageWithData:[[ObjectIP currentObject] image]];
        [controller addImage:objectImage];
    }
    
    [controller setInitialText:message];
    [container presentViewController:controller animated:YES completion:nil];
}

- (void)link:(BOOL)link block:(void (^)(NSError *))block
{
    if (link)
    {
        [PFFacebookUtils linkUser:[UserIP loggedUser] permissions:PERMISIONS block:^(BOOL succeeded, NSError *error)
        {
             [[UserIP loggedUser] setObject:[NSNumber numberWithBool:YES] forKey:@"isFacebookUser"];
             [[UserIP loggedUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 block(error);
             }];
        }];
    }
    else
    {
        [PFFacebookUtils unlinkUserInBackground:[UserIP loggedUser] block:^(BOOL succeeded, NSError *error)
         {
             [[UserIP loggedUser] setObject:[NSNumber numberWithBool:NO] forKey:@"isFacebookUser"];
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
