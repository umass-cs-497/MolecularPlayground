//
//  ConfigureWindowController.h
//  MPKinectSource
//
//  Created by Adam on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomImageView.h"

@interface ConfigureWindowController : NSWindowController <NSWindowDelegate> {
    
    NSImage *sampleImage;
    float minMeters;
    float maxMeters;
    float motionScale;
    BOOL upsideDown;
    CustomImageView *imageView;
    NSButton *saveButton;
}

@property (retain) NSImage *sampleImage;
@property (assign) IBOutlet CustomImageView *imageView;
@property (assign) IBOutlet NSButton *saveButton;
@property (assign) float minMeters;
@property (assign) float maxMeters;
@property (assign) float motionScale;
@property (assign) BOOL upsideDown;

- (IBAction)grabImage:(id)sender;
- (IBAction)buildBG:(id)sender;
@end
