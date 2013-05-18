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

@dynamic owner;
@dynamic state;
@dynamic type;
@dynamic descriptionObject;
@dynamic name;
@dynamic author;
@dynamic editorial;
@dynamic audioType;
@dynamic videoType;
@synthesize delegate = _delegate;

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

- (void)setDelegate:(id<iPrestaObjectDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - User Getters

- (id<iPrestaObjectDelegate>)delegate
{
    return _delegate;
}

#pragma mark -  Array Types Methods

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
    if (!error)      // Si error hay al buscar el objeto
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.requestData options:NSJSONReadingMutableContainers error:&error];
        if ([[response objectForKey:@"totalItems"] integerValue] > 0)
        {
            id volumeInfo = [[[response objectForKey:@"items"] objectAtIndex:0] objectForKey:@"volumeInfo"];
            
            self.name = @"";
            self.author = @"";
            self.editorial = @"";
            
            // Se setea el nombre del objeto
            if ([volumeInfo objectForKey:@"title"])
            {
                self.name = [volumeInfo objectForKey:@"title"];
                if ([volumeInfo objectForKey:@"subtitle"])
                {
                    self.name = [self.name stringByAppendingFormat:@" %@", [volumeInfo objectForKey:@"subtitle"]];
                }
            }
            
            // Se setea el autor del objeto
            if ([volumeInfo objectForKey:@"authors"])
            {
                for (NSString *author in [volumeInfo objectForKey:@"authors"])
                {
                    self.author = [self.author stringByAppendingString:author];
                    
                    if (!([[volumeInfo objectForKey:@"authors"] lastObject] == author))
                    {
                            self.author = [self.author stringByAppendingString:@", "];
                    }
                }
            }
            
            // Se setea la editorial del objeto
            if ([volumeInfo objectForKey:@"publisher"])
            {
                self.editorial = self.editorial = [volumeInfo objectForKey:@"publisher"];
            }
        }
        else
        {
            error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
        }
    }

    if ([_delegate respondsToSelector:@selector(getDataResponseWithError:)])
    {
        [_delegate getDataResponseWithError:error];
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
