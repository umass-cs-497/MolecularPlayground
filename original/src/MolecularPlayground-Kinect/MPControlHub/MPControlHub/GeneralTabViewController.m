//
//  MPGeneralTabViewController.m
//  MPControlHub
//
//  Created by Adam on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralTabViewController.h"
#import "ControlHubAppDelegate.h"

@interface GeneralTabViewController ()
- (void)updateStatus;
@end

@implementation GeneralTabViewController

@synthesize manager = manager_;
@synthesize uptimeStatus = uptimeStatus_;
@synthesize lastError = lastError_;
@synthesize jmolStatus = jmolStatus_;
@synthesize remoteStatus = remoteStatus_;
@synthesize kinectStatus = kinectStatus_;

- (id)initWithServerManager:(ServerManager *)manager {
    
    self = [super initWithNibName:@"GeneralTabViewController" bundle:nil];
    if (self) {
        
        manager_ = manager;
        [manager_ retain];
        
        [manager_.jmolServer addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionNew context:NULL];
        [manager_.remoteServer addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionNew context:NULL];
        [manager_.motionServer addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionNew context:NULL];
        [self updateStatus];
    }    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateStatus];
}

- (void)updateStatus
{
    self.jmolStatus = ([self.manager.jmolServer isConnected]) ? @"Connected" : @"Not Connected";
    self.remoteStatus = ([self.manager.remoteServer isConnected]) ? @"Connected" : @"Not Connected";
    self.kinectStatus = ([self.manager.motionServer isConnected]) ? @"Connected" : @"Not Connected";
}

- (void)dealloc
{
 
    [manager_.jmolServer removeObserver:self forKeyPath:@"connected"];
    [manager_.remoteServer removeObserver:self forKeyPath:@"connected"];
    [manager_.motionServer removeObserver:self forKeyPath:@"connected"];
    
    [manager_ release];
    [uptimeStatus_ release];
    [lastError_ release];
    [jmolStatus_ release];
    [kinectStatus_ release];
    [remoteStatus_ release];
    [super dealloc];
}

- (IBAction)start:(id)sender
{
    ControlHubAppDelegate *appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate startEverything];
}

- (IBAction)stop:(id)sender
{
    ControlHubAppDelegate *appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate stopEverything];    
}

- (IBAction)quitApp:(id)sender
{
    ControlHubAppDelegate *appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate stopEverything]; 
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)debugView:(id)sender
{
    NSButton *debugButton = (NSButton *)sender;
    if([debugButton.title isEqualToString:@"Open Debug View"]) {
        [self.manager sendDebugCommand:YES];
        debugButton.title = @"Close Debug View";
    }
    else {
        [self.manager sendDebugCommand:NO];
        debugButton.title = @"Open Debug View";
    }
}

- (IBAction)configView:(id)sender
{
    [self.manager sendConfigCommand];
}

@end
