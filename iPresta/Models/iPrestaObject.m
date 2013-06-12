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
#import "iPrestaNSError.h"
#import "ConnectionData.h"

@implementation iPrestaObject

static ObjectType typeSelected;
static iPrestaObject *currentObject;

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
@synthesize imageURL = _imageURL;
@synthesize delegate = _delegate;
@synthesize actualGive = _actualGive;

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

#pragma mark - User Setters

- (void)setDelegate:(id<iPrestaObjectDelegate>)delegate
{
    _delegate = delegate;
}

-  (void)setImageData:(NSData *)imageData
{
    _imageData = imageData;
}

-  (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
}

-  (void)setActualGive:(Give *)actualGive
{
    _actualGive = actualGive;
}

+ (void)setTypeSelected:(ObjectType)objectType
{
    typeSelected = objectType;
}

+ (void)setCurrentObject:(iPrestaObject *)object
{
    currentObject = object;
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

- (NSString *)imageURL
{
    return _imageURL;
}

- (Give *)actualGive
{
    return _actualGive;
}

+ (ObjectType)typeSelected
{
    return typeSelected;
}

+ (iPrestaObject *)currentObject
{
    return currentObject;
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
    
    if (typeSelected == BookType)
    {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", objectCode];
    }
    else if (typeSelected == AudioType || typeSelected == VideoType)
    {
        urlString = [NSString stringWithFormat:@"http://api.discogs.com/search?q=%@", objectCode];
    }
    
    ConnectionData *connection = [[ConnectionData alloc] initWithURL:[NSURL URLWithString:urlString] andID:@"getData"];
    [connection downloadData:self];
}

- (void)getSearchResults:(NSString *)param
{
    NSString *urlString;
    
    if (typeSelected == BookType)
    {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q='%@'&maxResults=20", param];
    }
    else if (typeSelected == AudioType || typeSelected == VideoType)
    {
        urlString = [NSString stringWithFormat:@"http://api.discogs.com/database/search?title=%@&type=release", param];
    }
    
    ConnectionData *connection = [[ConnectionData alloc] initWithURL:[NSURL URLWithString:urlString] andID:@"getSearchResults"];
    [connection downloadData:self];
}

- (void)dataFinishLoading:(ConnectionData *)connection error:(NSError *)error
{
    if (!error)      // Si error hay al buscar el/los objeto/s
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.requestData options:NSJSONReadingMutableContainers error:&error];

        if ([connection.identifier isEqual:@"getData"])
        {
            id volumeInfo;
            
            if (typeSelected == BookType)
            {
                volumeInfo = [[[response objectForKey:@"items"] objectAtIndex:0] objectForKey:@"volumeInfo"];
            }
            else if (typeSelected == AudioType || typeSelected == VideoType)
            {
                volumeInfo = [[[[[response objectForKey:@"resp"] objectForKey:@"search"] objectForKey:@"searchresults"] objectForKey:@"results"] objectAtIndex:0];
            }
            
            if (volumeInfo)
            {
                self.name = @"";
                self.author = @"";
                self.editorial = @"";
                self.type = typeSelected;
                
                if (typeSelected == BookType)
                {
                    [self setBookWithInfo:volumeInfo];
                }
                else if (typeSelected == AudioType || typeSelected == VideoType)
                {
                    [self setMediaWithInfo:volumeInfo];
                }
            }
            else
            {
                error = [[NSError alloc] initWithDomain:@"error" code:EMPTYOBJECTDATA_ERROR userInfo:nil];
            }
        
            if ([_delegate respondsToSelector:@selector(getDataResponseWithError:)])
            {
                [_delegate getDataResponseWithError:error];
            }
        }
        else if ([connection.identifier isEqual:@"getSearchResults"])
        {
            NSMutableArray *searchResultArray;
            id volumeInfoArray;
            
            if (typeSelected == BookType)
            {
                volumeInfoArray = [response objectForKey:@"items"];
            }
            else if (typeSelected == AudioType || typeSelected == VideoType)
            {
                volumeInfoArray = [response objectForKey:@"results"];
            }
            
            if ([volumeInfoArray count] > 0)
            {
                searchResultArray = [[NSMutableArray alloc] initWithCapacity:[volumeInfoArray count]];
                
                for (id volumeInfo in volumeInfoArray)
                {
                    iPrestaObject *object = [iPrestaObject object];
                    
                    object.name = @"";
                    object.author = @"";
                    object.editorial = @"";
                    object.type = typeSelected;
                    
                    if (typeSelected == BookType)
                    {
                        [object setBookWithInfo:[volumeInfo objectForKey:@"volumeInfo"]];
                    }
                    else if (typeSelected == AudioType || typeSelected == VideoType)
                    {
                        [object setMediaWithInfo:volumeInfo];
                    }
                    
                    [searchResultArray addObject:object];
                }
            }
            else
            {
                error = [[NSError alloc] initWithDomain:@"error" code:EMPTYSEARCH_ERROR userInfo:nil];
            }
            
            if ([_delegate respondsToSelector:@selector(getSearchResultsResponse:withError:)])
            {
                [_delegate getSearchResultsResponse:[searchResultArray copy] withError:error];
            }
            
            searchResultArray = nil;
            volumeInfoArray = nil;
        }
    }
    else
    {
        if ([connection.identifier isEqual:@"getData"])
        {
            if ([_delegate respondsToSelector:@selector(getDataResponseWithError:)])
            {
                [_delegate getDataResponseWithError:error];
            }
        }
        else if ([connection.identifier isEqual:@"getSearchResults"])
        {
            if ([_delegate respondsToSelector:@selector(getSearchResultsResponse:withError:)])
            {
                [_delegate getSearchResultsResponse:nil withError:error];
            }
        }
    }
}

#pragma mark - Set Object Methods

- (void)setBookWithInfo:(id)info
{
    // Se setea el nombre del objeto
    if ([info objectForKey:@"title"])
    {
        self.name = [info objectForKey:@"title"];
        if ([info objectForKey:@"subtitle"])
        {
            self.name = [self.name stringByAppendingFormat:@" %@", [info objectForKey:@"subtitle"]];
        }
    }
    
    // Se setea el autor del objeto
    if ([info objectForKey:@"authors"])
    {
        for (NSString *author in [info objectForKey:@"authors"])
        {
            self.author = [self.author stringByAppendingString:author];
            
            if (!([[info objectForKey:@"authors"] lastObject] == author))
            {
                self.author = [self.author stringByAppendingString:@", "];
            }
        }
    }
    
    // Se setea la editorial del objeto
    if ([info objectForKey:@"publisher"])
    {
        self.editorial = [info objectForKey:@"publisher"];
    }
}

- (void)setMediaWithInfo:(id)info
{
    if ([info objectForKey:@"title"])
    {
        id title = [[info objectForKey:@"title"] componentsSeparatedByString: @" - "];
        
        self.author = [title objectAtIndex:0];
        self.name = [title objectAtIndex:1];
    }
    if ([info objectForKey:@"thumb"])
    {
        self.imageURL = [info objectForKey:@"thumb"];
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

- (NSString *)firstLetter
{
    NSString *firstLetter = [[self.name substringWithRange:NSMakeRange(0, 1)] lowercaseString];
    NSString *secondLetter = [[self.name substringWithRange:NSMakeRange(1, 1)] lowercaseString];
    if ([firstLetter isEqual:@"c"] && [secondLetter isEqual:@"h"])
    {
        return @"ch";
    }
    if ([firstLetter isEqual:@"l"] && [secondLetter isEqual:@"l"])
    {
        return @"ll";
    }
    return firstLetter;
}

@end
