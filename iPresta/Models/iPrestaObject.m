//
//  Object.m
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "iPrestaNSString.h"
#import "iPrestaObject.h"
#import "User.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ConnectionData.h"

@implementation iPrestaObject

static ObjectType typeSelected;

@dynamic owner;
@dynamic state;
@dynamic type;
@dynamic descriptionObject;
@dynamic name;
@dynamic author;
@dynamic editorial;
@dynamic image;
@dynamic audioType;
@dynamic videoType;
@synthesize imageData = _imageData;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (NSString *)parseClassName
{
    return @"iPrestaObject";
}

+ (NSString *)title
{
    return [[iPrestaObject objectTypes] objectAtIndex:typeSelected];
}

#pragma mark - User Setters

- (void)setDelegate:(id<iPrestaObjectDelegate>)delegate
{
    _delegate = delegate;
}

-  (void)setImageData:(NSData *)imageData
{
    _imageData = imageData;
}

+ (void)setTypeSelected:(ObjectType)objectType
{
    typeSelected = objectType;
}

#pragma mark - User Getters

- (id<iPrestaObjectDelegate>)delegate
{
    return _delegate;
}

- (NSData *)imageData
{
    return _imageData;
}

+ (ObjectType)typeSelected
{
    return typeSelected;
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
    objectCode = [objectCode formatCode];
    
    NSString *urlString;
    
    if (self.type == BookType)
    {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", objectCode];
    }
    else if (typeSelected == AudioType || typeSelected == VideoType)
    {
        urlString = [NSString stringWithFormat:@"http://api.discogs.com/search?q=%@&f=json", objectCode];
    }
    
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
        
        self.name = @"";
        self.author = @"";
        self.editorial = @"";
        
        if (typeSelected == BookType)
        {
            [self setBookWithInfo:response error:&error];
        }
        else if (typeSelected == AudioType || typeSelected == VideoType)
        {
            [self setMediaWithInfo:response error:&error];
        }
    }

    if ([_delegate respondsToSelector:@selector(getDataResponseWithError:)])
    {
        [_delegate getDataResponseWithError:error];
    }
}

#pragma mark - Set Object Methods

- (void)setBookWithInfo:(id)info error:(NSError **)error
{
    if ([[info objectForKey:@"totalItems"] integerValue] > 0)
    {
        id volumeInfo = [[[info objectForKey:@"items"] objectAtIndex:0] objectForKey:@"volumeInfo"];
    
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
            self.editorial = [volumeInfo objectForKey:@"publisher"];
        }
        
        volumeInfo = nil;
    }
    else
    {
        *error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
    }
}

- (void)setMediaWithInfo:(id)info error:(NSError **)error
{
    if ([[[info objectForKey:@"resp"] objectForKey:@"status"] boolValue])
    {
        id volumeInfo = [[[[[info objectForKey:@"resp"] objectForKey:@"search"] objectForKey:@"searchresults"] objectForKey:@"results"] objectAtIndex:0];
        id title = [[volumeInfo objectForKey:@"title"] componentsSeparatedByString: @" - "];
        
        self.author = [title objectAtIndex:0];
        self.name = [title objectAtIndex:1];
        
        volumeInfo = nil;
    }
    else
    {
        *error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
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
    return [NSArray arrayWithObjects:@"CD", @"SACD", @"Vinilo", nil];
}

+ (NSArray *)videoObjectTypes
{
    return [NSArray arrayWithObjects:@"DVD", @"Bluray", @"VHS", nil];
}

@end
