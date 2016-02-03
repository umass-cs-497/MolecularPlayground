//
//  GeneralTabViewController.h
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Playground;

@interface GeneralTabViewController : NSViewController

@property (assign) Playground *playground;
@property (assign) LogCentral *logger;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)cameraSetup:(id)sender;

@end
