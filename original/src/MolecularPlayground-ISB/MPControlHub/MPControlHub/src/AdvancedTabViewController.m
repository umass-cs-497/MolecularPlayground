//
//  AdvancedTabViewController.m
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvancedTabViewController.h"
#import "Playground.h"
#import "Message.h"

@implementation AdvancedTabViewController

@synthesize playground = _playground;
@synthesize cameraTypeController = _cameraTypeController;

- (id)init
{
    self = [super initWithNibName:@"AdvancedTabViewController" bundle:nil];
    if(self) {
        _playground = [Playground sharedPlayground];
    }
    return self;
}

- (void)dealloc
{
    [_cameraTypeController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSDictionary *kinectInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Kinect", @"name", nil];
    NSDictionary *irInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Firewire", @"name", nil];
    NSArray *info = [NSArray arrayWithObjects:kinectInfo, irInfo, nil];
    [self.cameraTypeController setContent:info];
}

- (IBAction)chooseFile:(id)sender 
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    void (^openCompletion)(NSInteger) = ^(NSInteger result) {
		if(result == NSFileHandlingPanelOKButton) {
			NSURL *url = [[openPanel URLs] objectAtIndex:0];
			[[NSUserDefaults standardUserDefaults] setObject:[url path] forKey:MPJmolPathKey];
		}        
    };
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"app", @"jar", nil]];
    [openPanel beginSheetModalForWindow:[[self view] window] completionHandler:openCompletion];
}

- (IBAction)viewLogs:(id)sender 
{

}

- (IBAction)debugView:(id)sender 
{
    [self.playground.server sendMessageToCamera:[Message cameraDebugMessage]];
}

@end
