//
//  SourceSettings.m
//  MPMotionDriver
//
//  Created by Adam Williams on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SourceSettings.h"

@implementation SourceSettings
{
    NSUserDefaults *_defaults;
}

+ (SourceSettings *)sharedSettings
{
    static SourceSettings *sharedSettings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[SourceSettings alloc] init];
    });
    return sharedSettings;
}

- (id)init
{
    self = [super init];
    if(self) {
        _defaults = [[NSUserDefaults standardUserDefaults] retain];
    }
    return self;
}

- (void)dealloc
{
    [_defaults release];
    [super dealloc];
}

- (NSRect)activeRect
{
    float minX = [_defaults floatForKey:MPMinXKey];
    float maxX = [_defaults floatForKey:MPMaxXKey];
    float minY = [_defaults floatForKey:MPMinYKey];
    float maxY = [_defaults floatForKey:MPMaxYKey];
    
    NSRect activeRect;
    
    if(self.upsideDown) {
        activeRect.origin.x = MPFrameWidth - maxX;
        activeRect.origin.y = MPFrameHeight - maxY;
    }
    else {
        activeRect.origin.x = minX;
        activeRect.origin.y = minY;
    }
    activeRect.size.width = maxX - minX;
    activeRect.size.height = maxY - minY;
    
    return activeRect;
}

- (void)setActiveRect:(NSRect)activeRect
{
    float minX, maxX, minY, maxY;
    if(self.upsideDown) {
        minX = MPFrameWidth - (activeRect.origin.x + activeRect.size.width);
        maxX = minX + activeRect.size.width;
        minY = MPFrameHeight - (activeRect.origin.y + activeRect.size.height);
        maxY = minY + activeRect.size.height;
    }
    else {
        minX = activeRect.origin.x;
        maxX = minX + activeRect.size.width;
        minY = activeRect.origin.y;
        maxY = minY + activeRect.size.height;
    }
    
    [_defaults setFloat:minX forKey:MPMinXKey];
    [_defaults setFloat:minY forKey:MPMinYKey];
    [_defaults setFloat:maxX forKey:MPMaxXKey];
    [_defaults setFloat:maxY forKey:MPMaxYKey];
    [_defaults synchronize];    
}

- (BOOL)upsideDown
{
    return [_defaults boolForKey:MPUpsideDownKey];
}

- (void)setUpsideDown:(BOOL)upsideDown
{
    [_defaults setBool:upsideDown forKey:MPUpsideDownKey];
    [_defaults synchronize];
}

- (float)minMeters
{
    return [_defaults floatForKey:MPMinMetersKey];
}

- (void)setMinMeters:(float)minMeters
{
    [_defaults setFloat:minMeters forKey:MPMinMetersKey];
    [_defaults synchronize];
}

- (float)maxMeters
{
    return [_defaults floatForKey:MPMaxMetersKey];
}

- (void)setMaxMeters:(float)maxMeters
{
    [_defaults setFloat:maxMeters forKey:MPMaxMetersKey];
    [_defaults synchronize];
}

- (float)motionScale
{
    return [_defaults floatForKey:MPMotionScaleKey];
}

- (void)setMotionScale:(float)motionScale
{
    [_defaults setFloat:motionScale forKey:MPMotionScaleKey];
    [_defaults synchronize];
}

- (int)shutterSpeed
{
    return [_defaults integerForKey:MPShutterSpeedKey];
}

- (void)setShutterSpeed:(int)shutterSpeed
{
    [_defaults setInteger:shutterSpeed forKey:MPShutterSpeedKey];
    [_defaults synchronize];
}

@end
