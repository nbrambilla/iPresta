//
//  Connection.h
//  iPresta
//
//  Created by Nacho on 07/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionData : NSObject {
    NSMutableData *m_RequestData;
    id delegate;
    id identifier;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    NSData *requestData;
    BOOL workInProgress;
}

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSData *requestData;
@property (nonatomic, strong) id identifier;

- (void)setDelegate:(id)newDelegate;
- (id)initWithURL:(NSURL *)url;
-(id)initWithURL:(NSURL *)url andID:(id)connIdentifier;
- (id)initWithRequest:(NSURLRequest *)requestToData;
- (id)initWithRequest:(NSURLRequest *)requestToData andID:(id)connectionIdentifier;
- (void)downloadData:(id)connectionDelegate;
- (void)abortDownload;

@end

@interface NSObject(ConnectionDataDelegate)
- (void)dataFinishLoading:(ConnectionData *)connection error:(NSError *)error;

@end
          