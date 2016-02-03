//
//  AppDelegate.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MotionDriver.h"
#import "FirewireMotionSource.h"
#import "KinectMotionSource.h"

@interface AppDelegate ()
- (void)registerDefaultSettings;
@end

@implementation AppDelegate
{
    MotionDriver *_driver;
}

@synthesize window = _window;

- (void)dealloc
{
    [_driver release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self registerDefaultSettings];
    MotionSource *source = nil;
    NSInteger port = 31415;
    NSString *cameraType = @"Kinect";
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    if([args count] == 3) {
        cameraType = [args objectAtIndex:1];
        port = [[args objectAtIndex:2] intValue];
    }
    
    if([cameraType isEqualToString:@"Kinect"]) {
        source = [[KinectMotionSource alloc] init];
    }
    else {
        source = [[FirewireMotionSource alloc] init];
    }
    _driver = [[MotionDriver alloc] initWithMotionSource:source];
    [source release];
    [_driver startOnPort:port];
    
    [NSApp hide:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification 
{
    [_driver stop];
}

- (void)registerDefaultSettings
{
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.2f], MPMinMetersKey, 
                                 [NSNumber numberWithFloat:1.5f], MPMaxMetersKey,
                                 [NSNumber numberWithFloat:160.0f], MPMinXKey,
                                 [NSNumber numberWithFloat:120.0f], MPMinYKey,
                                 [NSNumber numberWithFloat:480.0f], MPMaxXKey,
                                 [NSNumber numberWithFloat:360.0f], MPMaxYKey,
                                 [NSNumber numberWithBool:NO], MPUpsideDownKey,
                                 [NSNumber numberWithInt:50], MPShutterSpeedKey,
                                 [NSNumber numberWithFloat:2.0f], MPMotionScaleKey, nil];
    [myDefaults registerDefaults:appDefaults];
}

@end
