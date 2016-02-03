//
//  MotionDriver.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MotionDriver.h"
#import "MotionMessage.h"

@interface MotionDriver ()
- (void)sendMessage:(MotionMessage *)message;
@end

@implementation MotionDriver
{
    GCDAsyncSocket *_socket;
    dispatch_queue_t _socketQueue;    
}

@synthesize source = _source;

- (id)initWithMotionSource:(MotionSource *)source
{
    self = [super init];
    if(self) {
        _source = [source retain];
        _source.delegate = self;
        _socketQueue = dispatch_queue_create("SocketQueue", NULL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_socketQueue);
    [_socket release];
    [_source release];
    [super dealloc];
}

- (void)startOnPort:(uint16_t)port
{
    NSError *error = nil;
    [_socket connectToHost:@"127.0.0.1" onPort:port error:&error];
    [_source start];
}

- (void)stop
{
    [_source hideConfigWindow];
    [_source stop];
    [_socket disconnect];
}

- (void)sendMessage:(MotionMessage *)message
{
    [_socket writeData:message.data withTimeout:10 tag:0];
}

#pragma mark - GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port 
{
    MotionMessage *loginMessage = [MotionMessage newLoginMessage];
    [self sendMessage:loginMessage];
    [loginMessage release];
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag 
{
    MotionMessage *message = [[MotionMessage alloc] initWithData:data];
    
    if([message isDebugViewMessage]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.source showDebugWindow];
            [NSApp activateIgnoringOtherApps:YES];
        });
        
    }
    else if([message isConfigureMessage]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.source showConfigWindow];
            [NSApp activateIgnoringOtherApps:YES];
        });
    }
    else if([message isQuitMessage]) {
        [self stop];
        [[NSApplication sharedApplication] terminate:self];
    }
    [message release];
    [_socket readDataWithTimeout:-1 tag:0];    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length 
{
    [_socket disconnect];
    return 0.0;
}

#pragma mark - MotionSourceDelegate

- (void)motionSource:(MotionSource *)source didRotateByX:(CGFloat)xAmount andY:(CGFloat)yAmount
{
    MotionMessage *message = [MotionMessage newMessageForRotation:CGPointMake(xAmount, yAmount)];
    [self sendMessage:message];
    [message release];
}

@end
