//
//  MPControlHubAppDelegate.h
//  MPControlHub
//
//  Created by Adam on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerManager.h"

@class HubWindowController;

@interface ControlHubAppDelegate : NSObject <NSApplicationDelegate> {
    HubWindowController *windowController_;
}

@property (readonly) ServerManager *manager;
@property (assign, getter = isStarted) BOOL started;

- (void)startEverything;
- (void)stopEverything;
- (void)startJmol;
- (void)startKinect;
- (void)killJmol;
- (void)killKinect;
@end
