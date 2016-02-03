//
//  AppDelegate.h
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HubWindowController.h"
#import "Playground.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    HubWindowController *_windowController;
}

@property (retain) Playground *playground;

- (void)addAppAsLoginItem;
- (void)deleteAppFromLoginItems;
- (void)registerDefaults;

@end
