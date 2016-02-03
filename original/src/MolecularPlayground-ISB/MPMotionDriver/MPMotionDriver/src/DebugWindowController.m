//
//  DebugWindowController.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DebugWindowController.h"

@implementation DebugWindowController

@synthesize debugView = _debugView;
@synthesize imageSource = _imageSource;

- (id)init
{
    return [self initWithWindowNibName:@"DebugWindow"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.debugView.imageSource = self.imageSource;
    self.debugView.allowsDrawing = NO;
    
}

@end
