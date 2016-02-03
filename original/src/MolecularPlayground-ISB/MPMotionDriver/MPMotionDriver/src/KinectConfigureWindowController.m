//
//  KinectConfigureWindowController.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KinectConfigureWindowController.h"
#import "SourceSettings.h"
#import <Kinect/Kinect.h>

@interface KinectConfigureWindowController ()
@property (retain, nonatomic) IBOutlet NSWindow *saveSheet;
@end

@implementation KinectConfigureWindowController

@synthesize minMeters = _minMeters;
@synthesize maxMeters = _maxMeters;
@synthesize upsideDown = _upsideDown;
@synthesize motionScale = _motionScale;

@synthesize saveSheet = _saveSheet;

- (id)init
{
    return [super initWithWindowNibName:@"KinectConfigureWindow"];
}

- (void)dealloc
{
    [_saveSheet release];
    [super dealloc];
}

- (void)refreshSettings
{
    
    [super refreshSettings];
    
    self.minMeters = [[SourceSettings sharedSettings] minMeters];
    self.maxMeters = [[SourceSettings sharedSettings] maxMeters];
    self.upsideDown = [[SourceSettings sharedSettings] upsideDown];
    self.motionScale = [[SourceSettings sharedSettings] motionScale];
    
    NSRect activeRect = [[SourceSettings sharedSettings] activeRect];
    
    NSValue *activeValue = [NSValue valueWithRect:activeRect];
    [self.imageView.drawings setObject:activeValue forKey:@"activeRect"];
    self.imageView.activeDrawingKey = @"activeRect";    
}

- (IBAction)saveConfig:(id)sender
{
    if(self.saveSheet == nil) {
        [NSBundle loadNibNamed:@"ConfigProgressWindow" owner:self];
    }
    
    [NSApp beginSheet:self.saveSheet modalForWindow:self.window 
                                      modalDelegate:nil 
                                     didEndSelector:NULL 
                                        contextInfo:NULL];
    
    [[SourceSettings sharedSettings] setMinMeters:self.minMeters];
    [[SourceSettings sharedSettings] setMaxMeters:self.maxMeters];
    [[SourceSettings sharedSettings] setMotionScale:self.motionScale];
    [[SourceSettings sharedSettings] setUpsideDown:self.upsideDown];
    
    NSRect activeRect = [[self.imageView.drawings objectForKey:@"activeRect"] rectValue];
    [[SourceSettings sharedSettings] setActiveRect:activeRect];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.configDelegate configControllerWillSave:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp endSheet:self.saveSheet];
            [self.saveSheet orderOut:self];
            [self close];            
        });
    });
}

- (IBAction)upsideDownValueChanged:(id)sender 
{
    self.imageView.upsideDown = self.upsideDown;
}
@end
