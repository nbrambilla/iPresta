//
//  Connection.m
//  Elche CF
//
//  Created by Nacho Brambilla on 28/11/12.
//  Copyright (c) 2012 eXular. All rights reserved.
//

#import "ConnectionData.h"
#import "iPrestaNSError.h"

@implementation ConnectionData

@synthesize request;
@synthesize requestData;
@synthesize identifier;

-(id)initWithRequest:(NSURLRequest*)requestToData
{
	self = [super init];
    
	if(self) {
        self.request = requestToData;
    }
    
	return self;
}

- (id)initWithRequest:(NSURLRequest *)requestToData andID:(id)connectionIdentifier
{
    self = [super init];
    
	if(self) {
        self.request = requestToData;
        self.identifier  = connectionIdentifier;
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
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
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
