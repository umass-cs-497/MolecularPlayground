//
//  AbstractServer.m
//  MPControlHub
//
//  Created by Adam Williams on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleServer.h"
#import "JSONKit.h"

#define HELLO_MSG     1
#define TIMEOUT       10.0

@interface SimpleServer ()
- (void)sendJSON:(NSString *)json;
- (void)waitForRead;
@end

@implementation SimpleServer

@synthesize port = port_;
@synthesize running = running_;
@synthesize connected = connected_;
@synthesize delegate = delegate_;
@synthesize magicWord = magicWord_;

- (id)initWithMagicWord:(NSString *)magicWord 
{    
    self = [super init];
    if(self) {
        socketQueue_ = dispatch_queue_create("SocketQueue", NULL);
        listenSocket_ = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue_];
        magicWord_ = [magicWord copy];
        
        running_ = NO;
        connected_ = NO;
        port_ = 31415;
        
    }
    
    return self;
}

- (id)init 
{
    return [self initWithMagicWord:@"unknown"];
}

- (void)dealloc 
{    
    dispatch_release(socketQueue_);
    [listenSocket_ release];
    [inSocket_ release];
    [outSocket_ release];
    [magicWord_ release];
    [super dealloc];
}

- (void)sendJSON:(NSString *)json
{
    NSString *terminatedString = [[NSString alloc] initWithFormat:@"%@\r\n", json];
    NSData *msgData = [terminatedString dataUsingEncoding:NSUTF8StringEncoding];
    [terminatedString release];
    [outSocket_ writeData:msgData withTimeout:TIMEOUT tag:0];
}

- (void)sendDictionary:(NSDictionary *)msg
{
    [self sendJSON:[msg JSONString]];
}

- (void)waitForRead
{
    [inSocket_ readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)start 
{
    if(self.running || self.delegate == nil || self.port < 0 || self.port > 65535) return;
    
    NSError *error = nil;
    if(![listenSocket_ acceptOnPort:self.port error:&error]) {
        
        NSLog(@"%@",[error description]);
        return;
    }
    self.running = YES;
}

- (void)stop 
{    
    if(!self.running)
        return;
    
    [listenSocket_ disconnect];
    [inSocket_ disconnect];
    [outSocket_ disconnect];
    
    self.running = NO;
}

- (void)disconnectClient
{
    [inSocket_ disconnect];
    [outSocket_ disconnect];
}

#pragma mark -
#pragma mark GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket 
{
	if([inSocket_ isConnected] && [outSocket_ isConnected]) {
        [newSocket disconnect];
        return;
    }
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:TIMEOUT tag:HELLO_MSG];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag 
{
    NSError *error = nil;
    NSDictionary *msg = [data objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON error:&error];
    
    if(error != nil) {
        NSLog(@"%@",[error description]);
    }
    //NSLog(@"%@",msg);
    if(tag == HELLO_MSG) {
        
        if(inSocket_ != nil && outSocket_ != nil) return;
        
        if([[msg valueForKey:@"magic"] isEqualToString:magicWord_]) {
            
            if([[msg valueForKey:@"role"] isEqualToString:@"in"] && inSocket_ == nil) {
                inSocket_ = sock;
                [inSocket_ retain];
                [self waitForRead];
            }
            else if([[msg valueForKey:@"role"] isEqualToString:@"out"] && outSocket_ == nil) {
                outSocket_ = sock;
                [outSocket_ retain];
            }
            
            if(inSocket_ != nil && outSocket_ != nil) {
                self.connected = YES;
            }
            
        }
        else {
            [sock disconnect];
        }
    }
    else {
        [self waitForRead];
        [self.delegate server:self receivedMessage:[data objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON]];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag 
{
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length 
{    
    [sock disconnect];
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err 
{    
    if(sock == inSocket_) {
        inSocket_ = nil;
        self.connected = NO;
    }
    else if(sock == outSocket_) {
        outSocket_ = nil;
        self.connected = NO;
    }
}

@end
