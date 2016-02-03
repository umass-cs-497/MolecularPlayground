//
//  MotionSource.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MotionSource+Private.h"

@implementation MotionSource
{
    DebugWindowController *_debugWindowController;
    NSThread *_motionThread;    
    
    uint8_t *_rgbBack, *_rgbFront;
    BOOL _rgbUpdate;
}

@synthesize delegate = _delegate;
@synthesize debugging = _debugging;
@synthesize configuring = _configuring;

- (id)init
{
    self = [super init];
    if(self) {
        _debugging = NO;
        _configuring = NO;
        _halt = YES;
        _frameSize.width = MPFrameWidth;
        _frameSize.height = MPFrameHeight;
        _rgbBack = malloc(MPFrameRGBSize);
        _rgbFront = malloc(MPFrameRGBSize); 
        _debugWindowController = nil;
    }
    return self;
}

- (void)dealloc
{
    [_debugWindowController release];
    [_configureWindowController release];
    [_motionThread release];
    
    free(_rgbBack);
    free(_rgbFront);
    
    [super dealloc];
}

- (NSWindowController *)configureWindowController
{
    return nil;
}

- (NSWindowController *)debugWindowController
{
    if(_debugWindowController == nil) {
        _debugWindowController = [[DebugWindowController alloc] init];
    }
    _debugWindowController.imageSource = self;
    _debugWindowController.window.delegate = self;
    return _debugWindowController;
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    if([notification object] == _debugWindowController.window) {
        self.debugging = NO;
        [_debugWindowController release];
        _debugWindowController = nil;
    }
    else if([notification object] == _configureWindowController.window) {
        self.configuring = NO;
        [_configureWindowController release];
        _configureWindowController = nil;
    }
}

- (void)start
{
    _halt = NO;
    [_motionThread release];
    _motionThread = [[NSThread alloc] initWithTarget:self selector:@selector(motionThread) object:nil];
    [_motionThread start];    
}

- (void)stop
{
    _halt = YES;
    if(![_motionThread isFinished]) usleep(1000);
    [_motionThread release];
    _motionThread = nil;
}

- (void)showDebugWindow
{
    if(self.configuring) return;
    [[self debugWindowController] showWindow:self];
    self.debugging = YES;
}

- (void)showConfigWindow
{
    if(self.debugging) return;
    [[self configureWindowController] showWindow:self];
    self.configuring = YES;
}

- (void)hideConfigWindow
{
    [_configureWindowController close];
}

- (void)rgbCallback:(IplImage *)image
{
    memcpy(_rgbBack, image->imageData, MPFrameRGBSize);
    @synchronized(self) {
        uint8_t *dest = _rgbBack;
        _rgbBack = _rgbFront;
        _rgbFront = dest;
        _rgbUpdate = YES;
    }
}

- (uint8_t *)rgbImage
{
    uint8_t *image = NULL;
    @synchronized(self) {
        if(_rgbUpdate) {
            _rgbUpdate = NO;
            image = _rgbFront;
            _rgbFront = malloc(MPFrameRGBSize);
        }
    }
    return image;
}

- (void)motionThread
{
    
}

@end
