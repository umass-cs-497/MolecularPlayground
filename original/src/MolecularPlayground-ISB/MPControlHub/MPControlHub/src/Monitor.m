//
//  Monitor.m
//  MPControlHub
//
//  Created by Adam Williams on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Monitor.h"
#import "Playground.h"

@implementation Monitor
{
    NSTask *_jmolTask;
    NSTask *_cameraTask;
}

@synthesize delegate = _delegate;

+ (Monitor *)sharedMonitor
{
    static Monitor *sharedMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[Monitor alloc] init];
    });
    return sharedMonitor;
}

- (void)startJmol
{
    NSString *jmolPath = [[NSUserDefaults standardUserDefaults] stringForKey:MPJmolPathKey];
    NSString *jmolArgs = [[NSUserDefaults standardUserDefaults] stringForKey:MPJmolArgsKey];
    NSInteger serverPort = [[NSUserDefaults standardUserDefaults] integerForKey:MPServerPortKey];
    NSString *jmolPort = [NSString stringWithFormat:@"%d", serverPort];
    
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
    NSInteger serverPort = [[NSUserDefaults standardUserDefaults] integerForKey:MPServerPortKey];
    NSString *cameraPort = [NSString stringWithFormat:@"%d", serverPort];
    NSString *cameraPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:MPMotionDriverPath];
    
    [_cameraTask release];
    _cameraTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObjects:cameraPath, @"--args", cameraString, cameraPort, nil]];
    [_cameraTask retain];
}

- (void)killCamera
{
    NSRunningApplication *cameraApp = [NSRunningApplication runningApplicationWithProcessIdentifier:[_cameraTask processIdentifier]];
    [cameraApp terminate];
}

@end
