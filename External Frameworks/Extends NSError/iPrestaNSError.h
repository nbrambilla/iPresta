//
//  iPrestaNSError.h
//  iPresta
//
//  Created by Nacho on 08/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

@interface NSError (iPrestaNSError)

#define CONNECTION_ERROR 100
#define URLCONNECTION_ERROR -1009
#define REQUESTTIMEOUT_ERROR -1001
#define LOGIN_ERROR 101
#define SIGNIN_ERROR 202
#define REQUESTPASSWORDRESET_ERROR 205
#define NOTCURRENTUSER_ERROR 700
#define EMPTYOBJECTDATA_ERROR 701
#define REPEATOBJECT_ERROR 702

- (void)manageErrorTo:(id)delegate;

@end
