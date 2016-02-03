//
//  Playground.m
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Playground.h"
#import "Message.h"
#import "Content.h"

@implementation Playground

@synthesize server = _server;
@synthesize contentSource = _contentSource;
@synthesize monitor = _monitor;
@synthesize running = _running;
@synthesize jmolStatus = _jmolStatus;
@synthesize cameraStatus = _cameraStatus;
@synthesize runningStatus = _runningStatus;

#pragma mark - Singleton accessor

+ (Playground *)sharedPlayground
{
    static Playground *sharedPlayground;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayground = [[Playground alloc] init];
    });
    return sharedPlayground;
}

- (id)init 
{    
    self = [super init];
    if(self) {
        _server = [[ServerController alloc] initWithPort:31415];
        _server.delegate = self;
        
        _running = NO;
        _jmolStatus = NSLocalizedString(@"Disconnected.", @"Jmol Disconnected Status");
        _cameraStatus = NSLocalizedString(@"Disconnected.", @"Camera Disconnected Status");
        _runningStatus = NSLocalizedString(@"Stopped.", @"Stopped status");
        
        _jmolTask = nil;
        _cameraTask = nil;
    }
    return self;
}

- (void)dealloc 
{
    [_server release];
    [_contentSource release];
    [_monitor release];
    [_jmolStatus release];
    [_cameraStatus release];
    [_runningStatus release];
    [_jmolTask release];
    [_cameraTask release];
    [super dealloc];
}

- (void)start
{
    NSInteger serverPort = [[NSUserDefaults standardUserDefaults] integerForKey:MPServerPortKey];
    
    self.server.port = serverPort;
    [self.server start];
    [self.contentSource reset];
    self.running = YES;
    [self performSelector:@selector(startJmol) withObject:nil afterDelay:1];
    [self performSelector:@selector(startCamera) withObject:nil afterDelay:5];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.runningStatus = [formatter stringFromDate:[NSDate date]];
    [formatter release];
}

- (void)stop
{
    self.running = NO;
    Message *quitMessage = [Message quitMessage];
    [self.server sendMessageToCamera:quitMessage];
    [self.server sendMessageToJmol:quitMessage];
    [self.server stop];
    self.runningStatus = NSLocalizedString(@"Stopped.", @"Stopped status");
}

- (void)quit
{
    [self stop];
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (void)startJmol
{
    NSString *jmolPath = [[NSUserDefaults standardUserDefaults] stringForKey:MPJmolPathKey];
    NSString *jmolArgs = [[NSUserDefaults standardUserDefaults] stringForKey:MPJmolArgsKey];
    NSString *jmolPort = [NSString stringWithFormat:@"%d", self.server.port];
    
    if(![jmolPath isAbsolutePath]) {
        jmolPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:jmolPath];
    }
    
    [_jmolTask release];
    if([[jmolPath pathExtension] isEqualToString:@"jar"]) {
        _jmolTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/java" arguments:[NSArray arrayWithObjects:@"-jar", jmolPath, jmolPort, jmolArgs, nil]];  
    }
    else {
        _jmolTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObjects:jmolPath, @"--args", jmolPort, jmolArgs, nil]];        
    }
    [_jmolTask retain];
}

- (void)killJmol
{
    NSRunningApplication *jmolApp = [NSRunningApplication runningApplicationWithProcessIdentifier:[_jmolTask processIdentifier]];
    [jmolApp terminate];
}

- (void)startCamera
{
    NSInteger cameraChoice = [[[NSUserDefaults standardUserDefaults] objectForKey:MPCameraSourceKey] integerValue];
    NSString *cameraString = (cameraChoice == MPCameraSourceKinect) ?  MPKinectCameraType : MPFirewireCameraType;
    NSString *cameraPort = [NSString stringWithFormat:@"%d", self.server.port];
    NSString *cameraPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:MPMotionDriverPath];
    
    [_cameraTask release];
    _cameraTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObjects:cameraPath, @"--args", cameraString, cameraPort, nil]];
    [_cameraTask retain];
}

#pragma mark - ContentSourceDelegate

- (void)contentSource:(ContentSource *)contentSource contentReady:(Content *)content
{
    NSLog(@"%@", content.title);
    Message *message = [Message jmolContentMessageWithContent:content atPath:[self.contentSource contentPath]];
    [self.server sendMessageToJmol:message];
}

#pragma mark - ServerControllerDelegate

- (void)serverController:(ServerController *)server didReceiveMessage:(Message *)message
{
    if([message isCameraMsg]) {
        [server sendMessageToJmol:message];
    }
    else if([message isJmolMsg]) {
        
        if([message isContentRequestMsg]) {
            [self.contentSource requestContent];
        }
        
    }
}

- (void)serverController:(ServerController *)server jmolDidConnect:(GCDAsyncSocket *)jmolSocket
{
    self.jmolStatus = NSLocalizedString(@"Connected.", @"Jmol Connected Status");
    [self.contentSource requestContent];
}

- (void)serverController:(ServerController *)server jmolDidDisconnect:(GCDAsyncSocket *)jmolSocket
{
    self.jmolStatus = NSLocalizedString(@"Disconnected.", @"Jmol Disconnected Status");    
}

- (void)serverController:(ServerController *)server cameraDidConnect:(GCDAsyncSocket *)motionSocket
{
    self.cameraStatus = NSLocalizedString(@"Connected.", @"Camera Connected Status");    
}

- (void)serverController:(ServerController *)server cameraDidDisconnect:(GCDAsyncSocket *)motionSocket
{
    self.cameraStatus = NSLocalizedString(@"Disconnected.", @"Camera Disconnected Status");        
}

@end
