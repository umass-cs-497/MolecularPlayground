//
//  AbstractServer.h
//  MPControlHub
//
//  Created by Adam Williams on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"

@interface SimpleServer : NSObject {
    
    dispatch_queue_t socketQueue_;
    GCDAsyncSocket *listenSocket_;
    GCDAsyncSocket *inSocket_;
    GCDAsyncSocket *outSocket_;
}

@property (assign) int port;
@property (assign, getter = isRunning) BOOL running;
@property (assign, getter = isConnected) BOOL connected;
@property (assign) id delegate;
@property (copy) NSString *magicWord;

- (id)initWithMagicWord:(NSString *)magicWord;

- (void)start;
- (void)stop;
- (void)disconnectClient;
- (void)sendDictionary:(NSDictionary *)msg;

@end

#pragma mark -

@protocol SimpleServerDelegate
 @optional
- (void)server:(SimpleServer *)server receivedMessage:(NSDictionary *)msg;
@end