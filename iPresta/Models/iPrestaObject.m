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
@dynamic barcode;
@dynamic image;
@dynamic audioType;
@dynamic videoType;
@synthesize imageData = _imageData;
@synthesize imageURL = _imageURL;
@synthesize delegate = _delegate;
@synthesize actualGive = _actualGive;


#pragma mark - Public Methods

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

- (BOOL)isEqualToObject:(iPrestaObject *)object
{
    if (self.barcode && [self.barcode isEqualToString:object.barcode]) return YES;

    NSString *firstChain = (self.author) ? [[self.name stringByAppendingString:self.author] serialize] : [self.name serialize];

    NSString *secondChain = (object.author) ? [[object.name stringByAppendingString:object.author] serialize] : [object.name serialize];
    
    NSInteger distance = [firstChain distance:secondChain];
    NSInteger coef = (int)([firstChain length] * 0.1 + 0.5);
    
    if (distance <= coef) return YES;
    //if ([[self.name serialize] isEqual:[object.name serialize]] && [[self.author serialize] isEqualToString:[object.author serialize]]) return YES;
    return  NO;
    
    firstChain = nil;
    secondChain = nil;
    distance = nil;
    coef = nil;
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

+ (NSString *)imageType
{
    return [[iPrestaObject imageTypes] objectAtIndex:typeSelected];
}

#pragma mark - Get Object Data Methods

- (void)getData:(NSString *)objectCode
{
    objectCode = [objectCode checkCode];
    
    NSString *urlString;
    
    if (typeSelected == BookType)
    {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", objectCode];
    }
    else if (typeSelected == AudioType || typeSelected == VideoType)
    {
        urlString = [NSString stringWithFormat:@"http://api.discogs.com/search?q=%@&f=json", objectCode];
        self.barcode = objectCode;
    }
    
    ConnectionData *connection = [[ConnectionData alloc] initWithURL:[NSURL URLWithString:urlString] andID:@"getData"];
    [connection downloadData:self];
}

- (void)getSearchResults:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset
{
    NSString *urlString;
    
    if (typeSelected == BookType)
    {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=%@&maxResults=%d&startIndex=%d", param, offset, page*offset];
    }
    else if (typeSelected == AudioType)
    {
        urlString = [NSString stringWithFormat:@"http://api.discogs.com/database/search?title=%@&type=release&page=%d&per_page=%d", param, page, offset];
    }
    
    else if (typeSelected == VideoType)
    {
        urlString = [NSString stringWithFormat:@"http://mymovieapi.com/?title=%@&type=json&episode=0&limit=%d&offset=%d", param, offset, page*offset];
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
                if (typeSelected == BookType)
                {
                    [self setBookWithInfo:volumeInfo];
                }
                else if (typeSelected == AudioType || typeSelected == VideoType)
                {
                    [self setAudioWithInfo:volumeInfo];
                }
            }
            else
            {
                [self setObject:[NSNull null] forKey:@"name"];
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
            else if (typeSelected == AudioType)
            {
                volumeInfoArray = [response objectForKey:@"results"];
            }
            else if (typeSelected == VideoType)
            {
                volumeInfoArray = [response objectForKey:@"result"];
            }

            if ([volumeInfoArray count] > 0)
            {
                searchResultArray = [[NSMutableArray alloc] initWithCapacity:[volumeInfoArray count]];
                
                for (id volumeInfo in volumeInfoArray)
                {
                    iPrestaObject *object = [iPrestaObject object];
                    
                    if (typeSelected == BookType)
                    {
                        [object setBookWithInfo:[volumeInfo objectForKey:@"volumeInfo"]];
                    }
                    else if (typeSelected == AudioType)
                    {
                        [object setAudioWithInfo:volumeInfo];
                    }
                    else if (typeSelected == VideoType)
                    {
                        [object setVideoWithInfo:volumeInfo];
                    }
                    
                    [searchResultArray addObject:object];
                }
            }
//            else
//            {
//                if (typeSelected == VideoType)
//                {
//                    if ([[response objectForKey:@"total_found"] integerValue]) error = [[NSError alloc] initWithDomain:@"error" code:EMPTYSEARCH_ERROR userInfo:nil];
//                }
//            }
            
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
        self.name = [[info objectForKey:@"title"] capitalizedString];
        if ([info objectForKey:@"subtitle"])
        {
            self.name = [self.name stringByAppendingFormat:@" %@", [[info objectForKey:@"subtitle"] capitalizedString]];
        }
    }
    // Se setea el autor del objeto
    if ([info objectForKey:@"authors"])
    {
        id authors = [info objectForKey:@"authors"];
        self.author = @"";
        
        for (NSString *author in authors)
        {
            self.author = [self.author stringByAppendingString:[author capitalizedString]];
            
            if (![[authors lastObject] isEqual:author])
            {
                self.author = [self.author stringByAppendingString:@", "];
            }
        }
    }
    // Se setea la editorial del objeto
    if ([info objectForKey:@"publisher"])
    {
        self.editorial = [[info objectForKey:@"publisher"] capitalizedString];
    }
    // se setea la imagen
    if ([info objectForKey:@"imageLinks"])
    {
        id images = [info objectForKey:@"imageLinks"];
        
        if ([images objectForKey:@"extraLarge"]) self.imageURL = [images objectForKey:@"extraLarge"];
        else if ([images objectForKey:@"large"]) self.imageURL = [images objectForKey:@"large"];
        else if ([images objectForKey:@"medium"]) self.imageURL = [images objectForKey:@"medium"];
        else if ([images objectForKey:@"small"]) self.imageURL = [images objectForKey:@"small"];
        else if ([images objectForKey:@"thumbnail"]) self.imageURL = [images objectForKey:@"thumbnail"];
        else if ([images objectForKey:@"smallThumbnail"]) self.imageURL = [images objectForKey:@"smallThumbnail"];
        
        images = nil;
    }
    // se setea el isbn
    if ([info objectForKey:@"industryIdentifiers"])
    {
        id barcodes = [info objectForKey:@"industryIdentifiers"];
        
        if ([barcodes count] == 1) self.barcode = [[barcodes objectAtIndex:0] objectForKey:@"identifier"];
        else if ([barcodes count] == 2)
        {
            if ([[[barcodes objectAtIndex:1] objectForKey:@"type"] isEqual: @"ISBN_13"]) self.barcode = [[barcodes objectAtIndex:1] objectForKey:@"identifier"];
            else self.barcode = [[barcodes objectAtIndex:0] objectForKey:@"identifier"];
        }
        else
        {
             self.barcode = [[barcodes objectAtIndex:1] objectForKey:@"identifier"];
        }
        
        barcodes = nil;
    }
}

- (void)setAudioWithInfo:(id)info
{
    // se setea el titulo y el autor
    if ([info objectForKey:@"title"])
    {
        id title = [[info objectForKey:@"title"] componentsSeparatedByString: @" - "];
        if ([title count] > 1)
        {
            self.author = [title objectAtIndex:0];
            self.name = [title objectAtIndex:1];
        }
    }
    // se setea la imagen
    if ([info objectForKey:@"thumb"])
    {
        self.imageURL = [info objectForKey:@"thumb"];
    }
}

- (void)setVideoWithInfo:(id)info
{
    // se setea el titulo
    if ([info objectForKey:@"title"])
    {
        self.name = [info objectForKey:@"title"];
    }
    // se setea el director
    if ([info objectForKey:@"directors"])
    {
        id directors = [info objectForKey:@"directors"];
        self.author = @"";
        
        for (NSString *director in directors)
        {
            self.author = [self.author stringByAppendingString:director];
            
            if (![[directors lastObject] isEqual:director])
            {
                self.author = [self.author stringByAppendingString:@", "];
            }
        }
    }
    // se setea la imagen
    if ([info objectForKey:@"poster"])
    {
        self.imageURL = [info objectForKey:@"poster"];
    }
    // se setea el identificador
    if ([info objectForKey:@"imdb_id"])
    {
        self.barcode = [info objectForKey:@"imdb_id"];
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

+ (NSArray *)imageTypes
{
    return [NSArray arrayWithObjects:@"book_icon.png", @"audio_icon.png", @"video_icon.png", @"other_icon.png", nil];
}

- (NSString *)firstLetter
{
    NSInteger len = [self.name length];
    
    if (len > 1)
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
    else return self.name;
}

@end
