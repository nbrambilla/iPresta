//
//  Object.m
//  iPresta
//
//  Created by Nacho on 16/03/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaObject.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ConnectionData.h"

@implementation iPrestaObject

static id<iPrestaObjectDelegate> delegate;

@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize type = _type;
@synthesize description = _description;
@synthesize name = _name;
@synthesize author = _author;
@synthesize editorial = _editorial;
@synthesize audioType = _audioType;
@synthesize videoType = _videoType;

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

- (void)setState:(ObjectState)state
{
    _state = state;
}

- (void)setType:(ObjectType)type
{
    _type = type;
}

- (void)setDescription:(NSString *)description
{
    _description = description;
}

- (void)setName:(NSString *)name
{
    [self setObject:name forKey:@"name"];
}

- (void)setAuthor:(NSString *)author
{
    _author = author;
}

- (void)setEditorial:(NSString *)editorial
{
    _editorial = editorial;
}

- (void)setAudioType:(AudioObjectType)audioType
{
    _audioType = audioType;
}

- (void)setVideoType:(VideoObjectType)videoType
{
    _videoType = videoType;
}

#pragma mark - User Getters

+ (id<iPrestaObjectDelegate>)delegate
{
    return delegate;
}

- (ObjectState)state
{
    return _state;
}

- (ObjectType)type
{
    return _type;
}

- (NSString *)description
{
    return _description;
}

- (NSString *)name
{
    return [self objectForKey:@"name"];
}

- (NSString *)author
{
    return  _author;
}

- (NSString *)editorial
{
    return _editorial;
}

- (AudioObjectType)audioType
{
    return _audioType;
}

- (VideoObjectType)videoType
{
    return _videoType;
}

#pragma mark - Get Objects From User

+ (void)getObjectsFromUser:(User *)user
{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Objeto"];
    [postQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
    
    [postQuery findObjectsInBackgroundWithTarget:[iPrestaObject class] selector:@selector(getObjectsFromUserResponse:error:)];
}

+ (void)getObjectsFromUserResponse:(NSArray *)result error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:delegate];
    
    if (error) [error manageErrorTo:delegate];     // Si hay al guardar el objeto
    else                                            // Si el objeto se guarda correctamente
    {
        if ([delegate respondsToSelector:@selector(getObjectsFromUserSuccess:)])
        {
            [delegate getObjectsFromUserSuccess:result];
        }
    }
}

#pragma mark - Save Methods

- (void)addToCurrentUser
{
    [ProgressHUD showProgressHUDIn:_delegate];
    
    PFObject *object = [PFObject objectWithClassName:@"Objeto"];
    [object setObject:[PFUser currentUser] forKey:@"owner"];
    [object setObject:[NSNumber numberWithInteger:_state] forKey:@"state"];
    [object setObject:[NSNumber numberWithInteger:_type] forKey:@"type"];
    [object setObject:self.name forKey:@"name"];
    if ([_author length] > 0)
    {
        [object setObject:_author forKey:@"author"];
    }
    if ([_editorial length] > 0)
    {
        [object setObject:_editorial forKey:@"editorial"];
    }
    if ([_description length] > 0)
    {
        [object setObject:_description forKey:@"description"];
    }
    if (_audioType != NoneAudioObjectType)
    {
        [object setObject:[NSNumber numberWithInteger:_audioType] forKey:@"audioType"];
    }
    if (_videoType != NoneVideoObjectType)
    {
        [object setObject:[NSNumber numberWithInteger:_videoType] forKey:@"videoType"];
    }
    
    [object saveInBackgroundWithTarget:self selector:@selector(saveResponse:error:)];
}

- (void)saveResponse:(PFObject *)object error:(NSError *)error
{
    [ProgressHUD hideProgressHUDIn:_delegate];
    
    if (error) [error manageErrorTo:_delegate];     // Si hay al guardar el objeto
    else                                            // Si el objeto se guarda correctamente
    {
        if ([_delegate respondsToSelector:@selector(addToCurrentUserSuccess)])
        {
            [_delegate addToCurrentUserSuccess];
        }
    }
}

#pragma mark - Get Object Data Methods

- (void)getObjectData:(NSString *)objectCode
{
    [ProgressHUD showProgressHUDIn:_delegate];
    
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
    [ProgressHUD hideProgressHUDIn:_delegate];
    
    if (error) [error manageErrorTo:_delegate];     // Si error hay al buscar el objeto
    else
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.requestData options:NSJSONReadingMutableContainers error:&error];
        if ([[response objectForKey:@"totalItems"] integerValue] > 0)
        {
            if ([_delegate respondsToSelector:@selector(getObjectDataSuccess)])
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
                
                if ([_delegate respondsToSelector:@selector(getObjectDataSuccess)])
                {
                    [_delegate getObjectDataSuccess];
                }
            }
        }
        else
        {
            error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
            
            [error manageErrorTo:_delegate];
        }
    }
}

#pragma mark - Constants Methods

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
