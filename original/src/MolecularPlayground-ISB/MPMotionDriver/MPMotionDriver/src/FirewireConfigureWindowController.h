//
//  FirewireConfigureWindowController.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConfigureWindowController.h"
#import "FirewireCamera.h"

@interface FirewireConfigureWindowController : ConfigureWindowController

@property (assign, nonatomic) float upsideDown;
@property (retain, nonatomic) FirewireCamera *camera;
@property (assign, nonatomic) int shutterSpeed;

- (id)initWithCamera:(FirewireCamera *)camera;
- (IBAction)saveConfig:(id)sender;

@end
