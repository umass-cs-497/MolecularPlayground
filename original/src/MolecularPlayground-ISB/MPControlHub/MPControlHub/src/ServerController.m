//
//  ServerController.m
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 University of Massachusetts. All rights reserved.
//

#import "ServerController.h"
#import "Message.h"

#define kLoginMsgTag    1
#define kLoginTimeout   10.0
#define kDefaultTimeout 5.0

@interface ServerController (Private)
- (void)sendMessage:(Message *)message toSocket:(GCDAsyncSocket *)socket;
@end

@implementation ServerController

@synthesize delegate = _delegate;
@synthesize port = _port;
@synthesize listening = _listening;

- (id)initWithPort:(int)port 
{    
    self = [super init];
    if(self) {
        _delegate = nil;
        _listening = NO;
        _port = port;
        _socketQueue = dispatch_queue_create("SocketQueue", NULL);
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

- (id)init 
{    
    return [self initWithPort:31415];
}

- (void)dealloc 
{    
    dispatch_release(_socketQueue);
    [_serverSocket release];
    [_jmolSocket release];
    [_cameraSocket release];
    
    [super dealloc];
}

#pragma mark - Private methods

- (void)sendMessage:(Message *)message toSocket:(GCDAsyncSocket *)socket
{
    [socket writeData:message.data withTimeout:kDefaultTimeout tag:0];
}

#pragma mark - Server stuff

- (void)start 
{    
    if(self.listening || self.port < 1 || self.port > 65535) return;
    
    NSError *error = nil;
    if(![_serverSocket acceptOnPort:self.port error:&error]) {
        
        [[LogCentral sharedInstance] logError:error];
        return;
    }
    self.listening = YES;
}

- (void)stop 
{
    [_serverSocket disconnect];
    [_jmolSocket disconnect];
    [_cameraSocket disconnect];
    
    self.listening = NO;
}

- (void)restart 
{    
    [self stop];
    [self start];
}

- (void)sendMessageToJmol:(Message *)message
{
    [self sendMessage:message toSocket:_jmolSocket];
}

- (void)sendMessageToCamera:(Message *)message
{
    [self sendMessage:message toSocket:_cameraSocket];
}

#pragma mark - GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket 
{
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:kLoginTimeout tag:kLoginMsgTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag 
{
    Message *message = [[Message alloc] initWithData:data];
    
    if([message isLoginType]) {
        if(_jmolSocket == nil && [message isJmolMsg]) {
            _jmolSocket = [sock retain];
            [self.delegate serverController:self jmolDidConnect:_jmolSocket];
        }
        else if(_cameraSocket == nil && [message isCameraMsg]) {
            _cameraSocket = [sock retain];
            [self.delegate serverController:self cameraDidConnect:_cameraSocket];
        }
        else {
            [sock disconnect];
            return;
        }
    }
    
    [self.delegate serverController:self didReceiveMessage:message];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    [message release];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if(sock == _jmolSocket) {
        [self.delegate serverController:self jmolDidDisconnect:_jmolSocket];
        [_jmolSocket release];
        _jmolSocket = nil;
    }
    else if(sock == _cameraSocket) {
        [self.delegate serverController:self cameraDidDisconnect:_cameraSocket];
        [_cameraSocket release];
        _cameraSocket = nil;
    }
}
@end
