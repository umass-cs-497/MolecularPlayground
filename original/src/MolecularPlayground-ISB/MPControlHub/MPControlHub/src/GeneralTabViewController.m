//
//  GeneralTabViewController.m
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralTabViewController.h"
#import "Playground.h"
#import "Message.h"

@implementation GeneralTabViewController

@synthesize playground = _playground;
@synthesize logger = _logger;

- (id)init
{
    self = [super initWithNibName:@"GeneralTabViewController" bundle:nil];
    if(self) {
        _playground = [Playground sharedPlayground];
        _logger = [LogCentral sharedInstance];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)start:(id)sender 
{
    [self.playground start];
}

- (IBAction)stop:(id)sender 
{
    [self.playground stop];
}

- (IBAction)quit:(id)sender 
{
    [self.playground quit];
}

- (IBAction)cameraSetup:(id)sender 
{
    [self.playground.server sendMessageToCamera:[Message cameraConfigureMessage]];
}

- (IBAction)hideHub:(id)sender 
{
    [NSApp hide:self];
}
@end
