//
//  ServerController.h
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 University of Massachusetts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol ServerControllerDelegate;
@class Message;

@interface ServerController : NSObject {
    GCDAsyncSocket *_serverSocket;
    GCDAsyncSocket *_jmolSocket;
    GCDAsyncSocket *_cameraSocket;
    
    dispatch_queue_t _socketQueue;
}

@property (assign) id<ServerControllerDelegate> delegate;
@property (assign, getter = isListening) BOOL listening;
@property (assign) NSInteger port;

- (id)initWithPort:(int)port;
- (void)start;
- (void)stop;
- (void)restart;
- (void)sendMessageToJmol:(Message *)message;
- (void)sendMessageToCamera:(Message *)message;

@end

@protocol ServerControllerDelegate <NSObject>
- (void)serverController:(ServerController *)server didReceiveMessage:(Message *)message;
- (void)serverController:(ServerController *)server jmolDidConnect:(GCDAsyncSocket *)jmolSocket;
- (void)serverController:(ServerController *)server jmolDidDisconnect:(GCDAsyncSocket *)jmolSocket;
- (void)serverController:(ServerController *)server cameraDidConnect:(GCDAsyncSocket *)motionSocket;
- (void)serverController:(ServerController *)server cameraDidDisconnect:(GCDAsyncSocket *)motionSocket;
@end