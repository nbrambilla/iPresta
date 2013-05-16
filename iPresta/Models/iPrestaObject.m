//
//  Object.m
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "iPrestaObject.h"
#import "User.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ConnectionData.h"

@implementation iPrestaObject

static id<iPrestaObjectDelegate> delegate;

@dynamic owner;
@dynamic state;
@dynamic type;
@dynamic descriptionObject;
@dynamic name;
@dynamic author;
@dynamic editorial;
@dynamic audioType;
@dynamic videoType;

+ (NSString *)parseClassName
{
    return @"iPrestaObject";
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - User Setters

+ (void)setDelegate:(id<iPrestaObjectDelegate>)userDelegate
{
    delegate = userDelegate;
}

#pragma mark - User Getters

+ (id<iPrestaObjectDelegate>)delegate
{
    return delegate;
}

- (NSString *)textState
{
    return [[iPrestaObject stateTypes] objectAtIndex:self.state];
}

- (NSString *)textType
{
    return [[iPrestaObject objectTypes] objectAtIndex:self.type];
}

- (NSString *)textAudioType
{
    return [[iPrestaObject audioObjectTypes] objectAtIndex:self.audioType];
}

- (NSString *)textVideoType
{
    return [[iPrestaObject videoObjectTypes] objectAtIndex:self.videoType];
}

#pragma mark - Get Object Data Methods

- (void)getData:(NSString *)objectCode
{
    [ProgressHUD showProgressHUDIn:delegate];
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", objectCode];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData                                                        timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:2.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    ConnectionData *connection = [[ConnectionData alloc] initWithRequest:request];
    [connection downloadData:self];
    
    urlString = nil;
    url = nil;
    request = nil;
}

- (void)dataFinishLoading:(ConnectionData *)connection error:(NSError *)error;
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];     // Si error hay al buscar el objeto
    else
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.requestData options:NSJSONReadingMutableContainers error:&error];
        if ([[response objectForKey:@"totalItems"] integerValue] > 0)
        {
            if ([delegate respondsToSelector:@selector(getDataSuccess)])
            {
                id volumeInfo = [[[response objectForKey:@"items"] objectAtIndex:0] objectForKey:@"volumeInfo"];
                
                // Se setea el nombre del objeto
                if ([volumeInfo objectForKey:@"title"])
                {
                    self.name = [volumeInfo objectForKey:@"title"];
                    if ([volumeInfo objectForKey:@"subtitle"])
                    {
                        self.name = [self.name stringByAppendingFormat:@" %@", [volumeInfo objectForKey:@"subtitle"]];
                    }
                }
                else
                {
                    self.name = @"";
                }
                
                // Se setea el autor del objeto
                self.author = ([volumeInfo objectForKey:@"authors"]) ? [[volumeInfo objectForKey:@"authors"] objectAtIndex:0] : @"";
                
                // Se setea la editorial del objeto
                self.editorial = ([volumeInfo objectForKey:@"publisher"]) ? self.editorial = [volumeInfo objectForKey:@"publisher"] : @"";
                
                [delegate getDataSuccess];
            }
        }
        else
        {
            error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
            
            [error manageErrorTo:delegate];
        }
    }
}

#pragma mark - Constants Methods

+ (NSArray *)stateTypes
{
    return [NSArray arrayWithObjects:@"No prestado", @"Prestado", @"A devolver", nil];
}

+ (NSArray *)objectTypes
{
    return [NSArray arrayWithObjects:@"Libro", @"Audio", @"Video", @"Otro", nil];
}

+ (NSArray *)audioObjectTypes
{
    return [NSArray arrayWithObjects:@"CD", @"SACD", @"Vinyl", nil];
}

+ (NSArray *)videoObjectTypes
{
    return [NSArray arrayWithObjects:@"DVD", @"Bluray", @"VHS", nil];
}

@end
