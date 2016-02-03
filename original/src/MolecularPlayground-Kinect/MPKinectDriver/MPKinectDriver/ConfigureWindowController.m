//
//  ConfigureWindowController.m
//  MPKinectSource
//
//  Created by Adam on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigureWindowController.h"
#import "MPKinectDriverAppDelegate.h"

@interface ConfigureWindowController ()
- (void)showImage;
@end

@implementation ConfigureWindowController

@synthesize sampleImage;
@synthesize minMeters;
@synthesize maxMeters;
@synthesize imageView;
@synthesize saveButton;
@synthesize motionScale;
@synthesize upsideDown;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [sampleImage release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    self.minMeters = [myDefaults floatForKey:@"minMeters"];
    self.maxMeters = [myDefaults floatForKey:@"maxMeters"]; 
    self.motionScale = [myDefaults floatForKey:@"motionScale"];
    self.upsideDown = [myDefaults boolForKey:@"upsideDown"];
}

- (void)showImage {
    
    MPKinectDriverAppDelegate *delegate = (MPKinectDriverAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    uint8_t *frame = [delegate createVideoData];
    if(frame == NULL) return;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CFDataRef rgbData = CFDataCreate(NULL, frame, FREENECT_VIDEO_RGB_SIZE);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(rgbData);
	
	CGImageRef rgbImage = CGImageCreate(640,480,8,24, 640*3, colorSpace,
										kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
	
	CFRelease(rgbData);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	NSImage *finalImage = [[NSImage alloc] initWithCGImage:rgbImage size:NSZeroSize];
    
    self.sampleImage = finalImage;
    
	[finalImage release];
	CGImageRelease(rgbImage);
	free(frame);
}

- (IBAction)grabImage:(id)sender {
    
    [self showImage];
    
}

- (IBAction)buildBG:(id)sender {
    
    self.saveButton.title = @"Saving...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
        [myDefaults setFloat:self.minMeters forKey:@"minMeters"];
        [myDefaults setFloat:self.maxMeters forKey:@"maxMeters"];
        [myDefaults setInteger:self.imageView.originX forKey:@"originX"];
        [myDefaults setInteger:self.imageView.originY forKey:@"originY"];
        [myDefaults setInteger:self.imageView.width forKey:@"width"];
        [myDefaults setInteger:self.imageView.height forKey:@"height"];
        [myDefaults setBool:self.upsideDown forKey:@"upsideDown"];
        [myDefaults synchronize];
        
        MPKinectDriverAppDelegate *delegate = (MPKinectDriverAppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate buildAndSaveBG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.window close];
        });
    });
}

- (void)windowWillClose:(NSNotification *)notification
{
    MPKinectDriverAppDelegate *delegate = (MPKinectDriverAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate doneConfiguring];
    self.saveButton.title = @"Save Config";
}

- (void)windowDidUpdate:(NSNotification *)notification
{
    [self showImage];
}

@end
