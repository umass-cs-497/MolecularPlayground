//
//  AdvancedTabViewController.h
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Playground;

@interface AdvancedTabViewController : NSViewController

@property (assign) Playground *playground;
@property (retain) IBOutlet NSArrayController *cameraTypeController;

- (IBAction)chooseFile:(id)sender;
- (IBAction)viewLogs:(id)sender;
- (IBAction)debugView:(id)sender;

@end
