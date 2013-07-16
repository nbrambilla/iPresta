//
//  Connection.m
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ConnectionData.h"
#import "iPrestaNSError.h"

#define TIMEOUT_INTERVAL 20.0

@implementation ConnectionData

@synthesize request;
@synthesize requestData;
@synthesize identifier;

-(id)initWithRequest:(NSMutableURLRequest*)requestToData
{
	self = [super init];
    
	if(self) {
        self.request = requestToData;
    }
    
	return self;
}

- (id)initWithURL:(NSURL *)url
{
	self = [super init];
    
	if(self) {
        self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL];
        [self.request setHTTPMethod:@"GET"];
        [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
	return self;
}

- (id)initWithURL:(NSURL *)url andID:(id)connIdentifier
{
	self = [super init];
    
	if(self) {
        self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL];
        [self.request setHTTPMethod:@"GET"];
        [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.identifier = connIdentifier;
    }
    
	return self;
}

- (id)initWithRequest:(NSMutableURLRequest *)requestToData andID:(id)connIdentifier
{
    self = [super init];
    
	if(self) {
        self.request = requestToData;
        self.identifier  = connIdentifier;
    }
    
	return self;
}

- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

-(void)downloadData:(id)connectionDelegate
{
	delegate = connectionDelegate;
    
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	if(connection) {
		workInProgress = YES;
		m_RequestData = [NSMutableData data];
	}
}

-(void)abortDownload
{
	if(workInProgress == YES) {
		[connection cancel];
		workInProgress = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [m_RequestData setLength:0];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_RequestData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    workInProgress = NO;
    
    // Verify that our delegate responds to the InternetImageReady method
    if ([delegate respondsToSelector:@selector(dataFinishLoading:error:)]) {
        // Call the delegate method and pass ourselves along.
        [delegate dataFinishLoading:self error:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(workInProgress == YES) {
		workInProgress = NO;
        
		self.requestData = m_RequestData;
        
		// Verify that our delegate responds to the InternetImageReady method
		if ([delegate respondsToSelector:@selector(dataFinishLoading:error:)]) {
			// Call the delegate method and pass ourselves along.
			[delegate dataFinishLoading:self error:nil];
		}
	}
}

- (void)viewDidUnload
{
    [self setRequest:nil];
    [self setRequestData:nil];
    [self setIdentifier:nil];
}

@end
