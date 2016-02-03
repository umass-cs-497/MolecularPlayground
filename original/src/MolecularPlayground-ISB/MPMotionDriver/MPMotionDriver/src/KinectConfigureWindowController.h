//
//  KinectConfigureWindowController.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConfigureWindowController.h"

@interface KinectConfigureWindowController : ConfigureWindowController

@property (assign, nonatomic) float minMeters;
@property (assign, nonatomic) float maxMeters;
@property (assign, nonatomic) BOOL upsideDown;
@property (assign, nonatomic) float motionScale;

- (IBAction)saveConfig:(id)sender;

@end
