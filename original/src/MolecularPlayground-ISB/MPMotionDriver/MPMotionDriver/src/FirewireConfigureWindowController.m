//
//  FirewireConfigureWindowController.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirewireConfigureWindowController.h"
#import "SourceSettings.h"

@implementation FirewireConfigureWindowController

@synthesize upsideDown = _upsideDown;
@synthesize camera = _camera;
@synthesize shutterSpeed = _shutterSpeed;

- (id)initWithCamera:(FirewireCamera *)camera
{
    self = [super initWithWindowNibName:@"FirewireConfigureWindow"];
    if(self) {
        _camera = [camera retain];
    }
    return self;
}

- (void)dealloc
{
    [_camera release];
    [super dealloc];
}

- (void)refreshSettings
{
    [super refreshSettings];
    
    self.upsideDown = [[SourceSettings sharedSettings] upsideDown];
    NSRect activeRect = [[SourceSettings sharedSettings] activeRect];
    
    NSValue *activeValue = [NSValue valueWithRect:activeRect];
    [self.imageView.drawings setObject:activeValue forKey:@"activeRect"];
    self.imageView.activeDrawingKey = @"activeRect";
    
    self.shutterSpeed = [[SourceSettings sharedSettings] shutterSpeed];
}

- (IBAction)saveConfig:(id)sender
{
    [[SourceSettings sharedSettings] setUpsideDown:self.upsideDown];
    [[SourceSettings sharedSettings] setShutterSpeed:self.shutterSpeed];
    
    NSRect activeRect = [[self.imageView.drawings objectForKey:@"activeRect"] rectValue];
    [[SourceSettings sharedSettings] setActiveRect:activeRect];
    
    [self.configDelegate configControllerWillSave:self];
    [self close];
}

- (IBAction)upsideDownValueChanged:(id)sender 
{
    self.imageView.upsideDown = self.upsideDown;
}

- (IBAction)shutterValueChanged:(id)sender
{
    [self.camera setShutterSpeed:self.shutterSpeed];
}

@end
