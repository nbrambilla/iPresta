//
//  Connection.h
//  Elche CF
//
//  Created by Nacho Brambilla on 28/11/12.
//  Copyright (c) 2012 eXular. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionData : NSObject {
    NSMutableData *m_RequestData;
    id delegate;
    id identifier;
    NSURLConnection *connection;
    NSURLRequest *request;
    NSData *requestData;
    BOOL workInProgress;
}

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSData *requestData;
@property (nonatomic, strong) id identifier;

- (void)setDelegate:(id)newDelegate;
- (id)initWithRequest:(NSURLRequest *)requestToData;
- (id)initWithRequest:(NSURLRequest *)requestToData andID:(id)connectionIdentifier;
- (void)downloadData:(id)connectionDelegate;
- (void)abortDownload;

@end

@interface NSObject(ConnectionDataDelegate)
- (void)dataFinishLoading:(ConnectionData *)connection error:(NSError *)error;

@end
          