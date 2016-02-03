//
//  ConfigureWindowController.m
//  MPMotionDriver
//
//  Created by Adam Williams on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigureWindowController.h"

@implementation ConfigureWindowController

@synthesize imageView = _imageView;
@synthesize imageSource = _imageSource;
@synthesize configDelegate = _configDelegate;

- (void)windowDidLoad
{
    [super windowDidLoad];

}

- (void)refreshSettings
{
    self.imageView.imageSource = self.imageSource;
    self.imageView.allowsDrawing = YES;
}

@end
